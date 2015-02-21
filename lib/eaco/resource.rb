module Eaco

  # A Resource is an object that can be authorized. It has an ACL, that
  # defines the access levels of designators. Actors have many designators
  # and the highest priority ones that matches the ACL yields the access
  # level of the Actor to this Resource.
  #
  # If there is no match between the Actor's designators and the ACL, then
  # access is denied. Negative authorizations are not yet implemented.
  #
  module Resource
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def role?(role)
        role.to_sym.in?(roles)
      end

      # Checks whether the ACL and permissiosn defined on this object
      # allow the given +user+ to perform the given +action+ on it, that
      # depends on the +role+ the user has on the target, calculated from
      # the +ACL+.
      #
      def allows?(action, user, record)
        return true if user.is_admin?

        role = role_of(user, record)
        return false unless role

        perms = permissions[role]
        return false unless perms

        perms.include?(action)
      end

      # Returns the given actor's role in the given record, or nil if no
      # access is granted.
      #
      def role_of(actor_or_designator, record)
        designators = if actor_or_designator.is_a?(Eaco::Designator)
          [actor_or_designator]

        elsif actor_or_designator.respond_to?(:designators)
          actor_or_designator.designators

        else
          raise Error, <<-EOF
            #{__method__} expects #{actor_or_designator.inspect}
            to be a Designator or to `respond_to?(:designators)`
          EOF
        end

        role_priority = nil
        record.acl.each do |designator, role|
          if designators.include?(designator)
            priority = roles_priority[role]
          end

          if priority && (role_priority.nil? || priority < role_priority)
            role_priority = priority
            break if role_priority == 0
          end
        end

        roles[role_priority] if role_priority
      end
    end

    # Returns +true+ if the given action is allowed to the given Actor
    #
    def allows?(action, actor)
      self.class.allows?(action, actor, self)
    end

    # Returns the role of the given +actor+
    #
    def role_of(actor)
      self.class.role_of(actor, self)
    end


    # Grants the given +designator+ access to this Resource as the given +role+.
    #
    # See ACL#add for details.
    #
    def grant(role, *designator)
      self.check_role!(role)

      change_acl {|acl| acl.add(role, *designator) }
    end

    # Revokes the given +designator+ access to this Resource.
    #
    # See ACL#del for details.
    #
    def revoke(*designator)
      change_acl {|acl| acl.del(*designator) }
    end

    # Grants the given set of designators access as to this Resource as the given +role+.
    #
    def batch_grant(role, designators)
      self.check_role!(role)

      change_acl do |acl|
        designators.each do |designator|
          acl.add(role, designator)
        end
        acl
      end
    end

    protected
      # Commenting this Ruby code is pleonastic.
      # <3
      #
      def change_acl
        acl = yield self.acl.try(:dup) || self.class.acl.new

        self.acl = acl unless acl == self.acl

        return self.acl
      end

      def check_role!(role)
        unless self.class.role?(role)
          raise Error,
            "The `#{role}' role is not valid for `#{self.class.name}' objects. " \
            "Valid roles are: `#{self.class.roles.join(', ')}'"
        end
      end
  end

end
