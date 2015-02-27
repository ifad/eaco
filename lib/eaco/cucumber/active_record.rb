begin
  require 'active_record'
rescue LoadError
  abort "ActiveRecord requires the rails appraisal. Try `appraisal cucumber`"
end

require 'yaml'

module Eaco
  module Cucumber

    ##
    # +ActiveRecord+ configuration and connection.
    #
    # Database configuration is looked up in +features/active_record.yml+ by
    # default. Logs are sent to +features/active_record.log+, truncating the
    # file at each run.
    #
    # Environment variables:
    #
    # * +EACO_AR_CONFIG+ specify a different +ActiveRecord+ configuration file
    # * +VERBOSE+ log to +stderr+
    #
    module ActiveRecord
      autoload :Document,   'eaco/cucumber/active_record/document'   # Resource
      autoload :User,       'eaco/cucumber/active_record/user'       # Actor
      autoload :Department, 'eaco/cucumber/active_record/department' # Designator source
      autoload :Position,   'eaco/cucumber/active_record/position'   # Designator source

      extend self

      ##
      # Looks up ActiveRecord and sets the +logger+.
      #
      # @return [Class] +ActiveRecord::Base+
      #
      def active_record
        @_active_record ||= ::ActiveRecord::Base.tap do |active_record|
          active_record.logger = ::Logger.new(active_record_log).tap {|l| l.level = 0}
        end
      end

      ##
      # Log to stderr if +VERBOSE+ is given, else log to
      # +features/active_record.log+
      #
      # @return [IO] the log destination
      #
      def active_record_log
        @_active_record_log ||= ENV['VERBOSE'] ? $stderr :
          'features/active_record.log'.tap {|f| File.open(f, "w+")}
      end

      ##
      # @return [Logger] the logger configured, logging to {.active_record_log}.
      #
      def logger
        active_record.logger
      end

      ##
      # @return [ActiveRecord::Connection] the current +ActiveRecord+ connection
      # object.
      #
      def connection
        active_record.connection
      end
      alias adapter connection

      ##
      # Returns an Hash wit the database configuration.
      #
      # Caveat:the returned +Hash+ has a custom +.to_s+ method that formats
      # the configuration as a +pgsql://+ URL.
      #
      # @return [Hash] the current database configuration
      #
      # @see {#config_file}
      #
      def configuration
        @_config ||= YAML.load(config_file.read).tap do |conf|
          def conf.to_s
            'pgsql://%s:%s@%s/%s' % values_at(
              :username, :password, :hostname, :database
            )
          end
        end
      end

      ##
      # @return [Pathname] the currently configured configuration file. Override
      #                    using the +EACO_AR_CONFIG' envinronment variable.
      #
      def config_file
        Pathname.new(ENV['EACO_AR_CONFIG'] || default_config_file)
      end

      ##
      # @return [String] +active_record.yml+ relative to this source file.
      #
      # @raise [Errno::ENOENT] if the configuration file is not found.
      #
      def default_config_file
        Pathname.new('features/active_record.yml').realpath

      rescue Errno::ENOENT => error
        raise error.class.new, <<-EOF.squeeze(' ')

          #{error.message}.

          Please define your Active Record database configuration in the
          default location, or specify your configuration file location by
          passing the `EACO_AR_CONFIG' environment variable.
        EOF
      end

      ##
      # Establish ActiveRecord connection using the given configuration hash
      #
      # @param config [Hash] the configuration to use, {#configuration} by default.
      #
      # @return [ActiveRecord::ConnectionAdapters::ConnectionPool]
      #
      # @raise [ActiveRecord::ActiveRecordError] if cannot connect
      #
      def connect!(config = self.configuration)
        unless ENV['VERBOSE']
          config = config.merge(min_messages: 'WARNING')
        end

        active_record.establish_connection(config)
      end

      ##
      # Loads the defined {ActiveRecord#schema}
      #
      # @return [nil]
      #
      def define_schema!
        log_stdout { load 'eaco/cucumber/active_record/schema.rb' }
      end

      protected

      ##
      # Captures stdout emitted by the given +block+ and logs it
      # as +info+ messages.
      #
      # @param block [Proc]
      # @return [nil]
      # @see {Rake::Utils.capture_stdout}
      #
      def log_stdout(&block)
        stdout = Rake::Utils.capture_stdout(&block)

        stdout.split("\n").each do |line|
          logger.info line
        end

        nil
      end
    end

  end
end
