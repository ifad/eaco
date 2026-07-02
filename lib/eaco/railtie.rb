# frozen_string_literal: true

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
      # Application constants (models) cannot be autoloaded while Rails is
      # booting: with Zeitwerk they become available only once the app is
      # fully initialized. +to_prepare+ runs after boot and again on each
      # code reload in development.
      app.config.to_prepare do
        Eaco.parse_default_rules_file!
      end
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