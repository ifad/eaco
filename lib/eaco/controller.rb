require 'active_support/concern'

module Eaco

  # An ActionController plugin to verify authorization in Rails applications.
  #
  # Tested on Rails 3.2 and up on Ruby 2.0 and up.
  #
  module Controller
    extend ActiveSupport::Concern

    included do
      before_filter :confront_eaco
    end

    # Controller authorization DSL.
    #
    module ClassMethods
      # Defines the ability required to access a given controller action.
      #
      # Example:
      #
      #   class DocumentsController < ApplicationController
      #     authorize :index,           [:folder, :index]
      #     authorize :show,            [:folder, :read]
      #     authorize :create, :update, [:folder, :write]
      #   end
      #
      # Here `@folder` is expected to be an authorized +Resource+, and for the
      # `index` action the +current_user+ is checked to `can?(:index, @folder)`
      # while for `show`, `can?(:read, @folder)` and for `create` and `update`
      # checks that it `can?(:write, @folder)`.
      #
      # The special `:all` action name requires the given ability on the given
      # Resource for all actions.
      #
      # If an action has no authorization defined, access is granted.
      #
      def authorize(*actions)
        target = actions.pop

        actions.each {|action| authorization_permissions.update(action => target)}
      end

      # Returns the permission required to access the given action.
      #
      def permission_for(action)
        authorization_permissions[action] || authorization_permissions[:all]
      end

      protected
        # Permission requirements configured on this controller.
        #
        def authorization_permissions
          @_authorization_permissions ||= {}
        end
    end

    # Asks Eaco whether thou shalt pass or not.
    #
    # The implementation is left in this method's body, despite a bit long for
    # many's taste, as it is pretty imperative and simple code. Moreover, the
    # less we pollute ActionController's namespace, the better.
    #
    def confront_eaco
      action = params[:action].intern
      resource_ivar, permission = self.class.permission_for(action)

      if resource_ivar && permission
        resource = instance_variable_get(['@', resource_ivar].join.intern)

        if resource.nil?
          raise Error, <<-EOF
            @#{resource_ivar} is not set, can't authorize #{self}##{action}
          EOF
        end

        unless current_user.can? permission, resource
          raise Forbidden, <<-EOF
            `#{current_user}' not authorized to `#{action}' on `#{resource}'
          EOF
        end
      end
    end
  end

end
