begin
  require 'active_record'
rescue LoadError
  abort "ActiveRecord requires the rails appraisal. Try `appraisal cucumber`"
end

module Eaco
  module Cucumber

    ##
    # +ActiveRecord+ configuration and connection.
    #
    # Uses features/support/active_record.yml by default, overridable via the
    # +EACO_AR_CONFIG+ environment variable.
    #
    module ActiveRecord
      ##
      # Set up ActiveRecord
      #
      # @return [Class] +ActiveRecord::Base+
      #
      def active_record
        @_active_record ||= ::ActiveRecord::Base.tap do |active_record|
          active_record.logger = ::Logger.new(active_record_log).tap {|l| l.level = 0}
        end
      end

      ##
      # Log to stderr if VERBOSE is given, else log to
      # features/active_record.log
      #
      # @return [IO] the log destination
      #
      def active_record_log
        @_active_record_log ||= ENV['VERBOSE'].present? ? $stderr :
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
      # @return [Hash] the current database configuration
      #
      # Caveat: the returned +Hash+ has a custom +.to_s+ method that formats
      # the configuration as a +pgsql://+ URL.
      #
      # @see {.config_file}
      #
      def config
        @_config ||= YAML.load(config_file.read).tap do |conf|
          conf.symbolize_keys!

          def conf.to_s
            'pgsql://%s:%s@%s/%s' % values_at(
              :username, :password, :hostname, :database
            )
          end
        end

      rescue Errno::ENOENT => error
        raise Eaco::Error, <<-EOF
          File not found: #{error.message}.
          Please define your Active Record database configuration
          in `features/support/active_record.yml' or specify your configuration
          file via the `EACO_AR_CONFIG' environment variable
        EOF
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
      def default_config_file
        File.join(File.dirname(__FILE__), '..', 'active_record.yml')
      end

      ##
      # Establish ActiveRecord connection using the given configuration hash
      #
      # @param config [Hash] the configuration to use, {.default_configuration}
      #                      by default.
      #
      # @return [void]
      #
      # @raise [ActiveRecord::ActiveRecordError] if cannot connect
      #
      def connect!(config = self.default_configuration)
        unless ENV['VERBOSE'].present?
          config = config.merge(min_messages: 'WARNING')
        end
        active_record.establish_connection config
      end

      ##
      # Drops and recreates the database specified in the {.config}.
      #
      # TODO untangle from postgres
      #
      # @return [void]
      #
      def recreate_database!
        database = config.fetch(:database)
        connect! config.merge(database: :postgres) # FIXME

        connection.drop_database   database
        connection.create_database database
        connect! config

        logger.info "Connected to #{config}"
      end
    end

  end
end
