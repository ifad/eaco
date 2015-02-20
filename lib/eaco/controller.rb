require 'active_support/concern'

module Eaco

  module Controller
    extend ActiveSupport::Concern

    included do
      before_filter :check_authorization
    end

    module ClassMethods
      # Defines the ability required to access a given controller action.
      #
      # Example:
      #
      #   class DocumentsController
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

      def authorization_permissions
        @_authorization_permissions ||= {}
      end

      def permission_for(action)
        authorization_permissions[action] || authorization_permissions[:all]
      end
    end

    # Checks that the current user can access this action
    #
    def check_authorization
      action = params[:action].intern
      ivar, perm = self.class.permission_for(action)

      if ivar && perm
        resource = instance_variable_get(['@', ivar].join.intern)

        if resource.nil?
          raise Error, "Cannot find @#{ivar} while authorizing #{self}##{action}"
        end

        unless current_user.can? perm, resource
          raise Forbidden, "`#{current_user}' not authorized to `#{action}' on `#{resource}'"
        end
      end
    end
  end

end
