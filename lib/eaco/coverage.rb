require 'coveralls'
require 'simplecov'
require 'eaco/rake'

module Eaco

  ##
  # Integration with code coverage tools.
  #
  # Loading this module will start collecting coverage data.
  #
  module Coverage
    extend self

    ##
    # Starts collecting coverage data.
    #
    # @return [nil]
    #
    def start!
      Coveralls.wear_merged!(&simplecov_configuration)

      nil
    end

    ##
    # Reports coverage data to the remote service
    #
    # @return [nil]
    #
    def report!
      simplecov
      Coveralls.push!

      nil
    end

    ##
    # Formats coverage results using the default formatter.
    #
    # @return [String] Coverage summary
    #
    def format!
      Rake::Utils.capture_stdout do
        result && result.format!
      end.strip
    end

    private

    ##
    # The coverage result
    #
    # @return [SimpleCov::Result]
    #
    def result
      simplecov.result
    end

    ##
    # Configures simplecov using {.simplecov_configuration}
    #
    # @return [Class] +SimpleCov+
    #
    def simplecov
      SimpleCov.configure(&simplecov_configuration)
    end

    ##
    # Configures +SimpleCov+ to use a different directory
    # for each different appraisal +Gemfile+.
    #
    # @return [Proc] a +SimpleCov+ configuration block.
    #
    def simplecov_configuration
      proc do
        gemfile = Eaco::Rake::Utils.gemfile
        coverage_dir "coverage/#{gemfile}"
        add_filter ['/features', '/spec']
      end
    end
  end

end
