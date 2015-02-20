module Eaco

  class Railtie < ::Rails::Railtie
    initializer 'eaco.parse-rules' do
      Eaco.parse!

      unless Rails.configuration.cache_classes
        ActionDispatch::Reloader.to_prepare do
          Authorization.parse!
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
