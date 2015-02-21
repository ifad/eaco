module Eaco

  autoload :Controller, 'eaco/controller'

  # Initializer for Rails 3 and up
  #
  # * Parses the configuration rules upon startup and, in development, after a
  #   console `reload!`.
  #
  # * Installs +Eaco::Controller+ authorization filters in
  # +ActionController::Base+.
  #
  class Railtie < ::Rails::Railtie
    initializer 'eaco.parse-rules' do
      Eaco.setup!

      unless Rails.configuration.cache_classes
        ActionDispatch::Reloader.to_prepare do
          Eaco.setup!
        end
      end
    end

    initializer 'eaco.action-controller' do
      ActiveSupport.on_load :action_controller do

        ActionController::Base.instance_eval do
          include Eaco::Controller
        end

      end
    end
  end

end
