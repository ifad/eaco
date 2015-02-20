module Eaco

  module Controller
    extend ActiveSupport::Concern

    module ClassMethods
      def authorize(*actions)
        perms  = (@_authz_permissions_for ||= {})
        target = actions.pop

        actions.each {|action| perms.update(action => target)}

        before_filter :check_authorization
      end

      def authorization_permissions
        @_authz_permissions_for
      end
    end

    def check_authorization
      action = params[:action].intern
      ivar, perm = self.class.authorization_permissions[action] || self.class.authorization_permissions[:all]

      if ivar && perm
        target = instance_variable_get ['@', ivar].join.intern

        if target.nil?
          raise Error, "Cannot find @#{ivar} while authorizing #{self}##{action}"
        end

        unless current_user.can? perm, target
          raise Forbidden, "`#{current_user}' not authorized to `#{action}' on `#{target}'"
        end

      end
    end
  end

end
