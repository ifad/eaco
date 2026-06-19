module Eaco

  autoload :Controller, 'eaco/controller'

  ##
  # Initializer for Rails 3 and up.
  #
  # * Parses the configuration rules upon startup and, in development, after a
  #   console +reload!+.
  #
  # * Installs {Controller} authorization filters in +ActionController::Base+.
  #
  class Railtie < ::Rails::Railtie

    ##
    # Calls {Eaco.parse_default_rules_file!}
    #
    # @!method parse_rules
    #
    initializer 'eaco.parse_rules' do |app|
      # :nocov:
      # Parse in a to_prepare hook, not inline: the rules reference application
      # models (e.g. ::Dossier), which under Zeitwerk (Rails 7+) cannot be
      # autoloaded during initialization. to_prepare runs after the app is
      # initialized (once at boot in every env, and again on each dev reload),
      # by which point the autoloaders are ready.
      app.config.to_prepare { Eaco.parse_default_rules_file! }
      # :nocov:
    end

    ##
    # Adds {Controller} to +ActionController::Base+
    #
    # @!method install_controller_runtime
    #
    initializer 'eaco.install_controller_runtime' do
      # :nocov:
      ActiveSupport.on_load :action_controller do

        ActionController::Base.instance_eval do
          include Eaco::Controller
        end

      end
      # :nocov:
    end
  end

end
