require 'eaco/coverage'

module Eaco
  module Rake

    ##
    # Defines the default Eaco rake task. It runs tests and generates the docs.
    #
    # Usage:
    #
    #   Eaco::Rake::DefaultTask.new
    #
    class DefaultTask
      include ::Rake::DSL if defined?(::Rake::DSL)

      ##
      # Main +Eaco+ rake task.
      #
      # If running appraisals or running within Travis CI, run all specs and
      # cucumber features.
      #
      # The concept here is to prepare the environment with the gems set we
      # are testing against, and this is done by Appraisals and Travis, albeit
      # in a different way. The first uses the +Appraisals+ file, the second
      # instead relies on the +.travis.yml+ configuration.
      #
      # Documentation is generated at the end, once if running locally, but
      # multiple times, once for each appraisal, on Travis.
      #
      def initialize
        if running_appraisals?
          task :default do
            run_specs
            run_cucumber
            output_coverage
          end

        elsif running_in_travis?
          task :default do
            run_specs
            run_cucumber
            report_coverage
          end

        else
          desc 'Appraises specs and cucumber, generates documentation'
          task :default do
            run_appraisals
            generate_documentation
          end

        end
      end

      ##
      # Runs all appraisals (see +Appraisals+ in the source root)
      # against the defined Rails version and generates the source
      # documentation using Yard.
      #
      # Runs them in a subprocess as the appraisals gem makes use
      # of fork/exec hijacking the process session root.
      #
      # @raise [RuntimeError] if the appraisals run fails.
      #
      # @return [void]
      #
      def run_appraisals
        croak 'Running all appraisals'

        pid = fork { invoke :appraisal }
        _, status = Process.wait2(pid)
        unless status.exitstatus == 0
          bail "Appraisals failed with status #{status.exitstatus}"
        end
      end

      ##
      # Generate the documentation using +Yard+.
      #
      def generate_documentation
        croak 'Generating documentation'

        invoke :yard
      end

      ##
      # Runs all specs under the +spec/+ directory
      #
      # @return [void]
      #
      def run_specs
        croak 'Running specs'

        invoke :spec
      end

      ##
      # Runs all cucumber features in the +features/+ directory
      #
      # @return [void]
      #
      def run_cucumber
        croak 'Evaluating cucumber features'

        invoke :cucumber
      end

      private

      ##
      # Invokes the given rake task.
      #
      # @param task [Symbol] the task to invoke.
      # @return [void]
      #
      def invoke(task)
        ::Rake::Task[task].invoke
      end

      ##
      # Reports coverage data
      #
      # @return [void]
      #
      def report_coverage
        Eaco::Coverage.report!
      end

      ##
      # Formats code coverage results and prints a summary
      #
      # @return [void]
      #
      def output_coverage
        summary = Eaco::Coverage.format!
        croak summary
      end

      ##
      # Fancily logs the given +msg+ to +$stderr+.
      #
      # @param msg [String] the message to bail out.
      #
      # @return [nil]
      #
      def croak(msg)
        $stderr.puts fancy(with_appraisal(msg))
      end

      ##
      # Bails out the given error message.
      #
      # @param msg [String] the message to bail
      # @raise [RuntimeError]
      #
      def bail(msg)
        raise RuntimeError, fancy(msg)
      end

      ##
      # Adds the current appraisal name to msg, if present
      #
      # @param msg [String]
      # @return [String]
      #
      def with_appraisal(msg)
        if gemfile
          msg = "%s \033[1;31m[%s]" % [msg, gemfile]
        end

        return msg
      end

      ##
      # Makes +msg+ fancy.
      #
      # @param msg [String]
      # @return [String]
      #
      def fancy(msg)
        <<-EOF
\033[0m
\033[1;32m>>>
\033[1;32m>>> EACO: \033[1;37m#{msg}
\033[1;32m>>>
\033[0m
        EOF
      end

      ##
      # @see {Rake::Utils.gemfile}
      # @private
      #
      def gemfile
        Rake::Utils.gemfile
      end

      ##
      # @return [Boolean] Are we running appraisals?
      #
      def running_appraisals?
        ENV["APPRAISAL_INITIALIZED"]
      end

      ##
      # @return [Boolean] Are we running on Travis CI?
      #
      def running_in_travis?
        ENV["TRAVIS"]
      end
    end

  end
end
