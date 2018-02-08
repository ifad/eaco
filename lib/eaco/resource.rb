module Eaco

  ##
  # A Resource is an object that can be authorized. It has an {ACL}, that
  # defines the access levels of {Designator}s. {Actor}s have many designators
  # and the highest priority ones that matches the {ACL} yields the access
  # level of the {Actor} to this {Resource}.
  #
  # If there is no match between the {Actor}'s designators and the {ACL}, then
  # access is denied.
  #
  # Authorized resources are defined through the DSL, see {DSL::Resource}.
  #
  # TODO Negative authorizations
  #
  # @see ACL
  # @see Actor
  # @see Designator
  #
  # @see DSL::Resource
  #
  module Resource

    # @private
    def self.included(base)
      base.extend ClassMethods
    end

    ##
    # Singleton methods added to authorized Resources.
    #
    module ClassMethods
      ##
      # @return [Boolean] checks whether the given +role+ is valid in the
      # context of this Resource.
      #
      # @param role [Symbol] role name.
      #
      def role?(role)
        roles.include?(role.to_sym)
      end

      ##
      # Checks whether the {ACL} and permissions defined on this Resource
      # allow the given +actor+ to perform the given +action+ on it, that
      # depends on the +roles+ the user has on the resource, calculated from
      # the {ACL}.
      #
      # @param action [Symbol]
      # @param actor [Actor]
      # @param resource [Resource]
      #
      # @return [Boolean]
      #
      def allows?(action, actor, resource)
        return true if actor.is_admin?

        roles = roles_of(actor, resource)

        return false if roles.empty?

        perms = roles.flat_map do |role|
          permissions[role]
        end.uniq

        perms.include?(action.to_sym)
      end

      ##
      # @return [Symbol] the given +actor+ role in the given resource, or
      # +nil+ if no access is granted.
      #
      # @param actor_or_designator [Actor or Designator]
      # @param resource [Resource]
      #
      def role_of(actor_or_designator, resource)
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
        resource.acl.each do |designator, role|
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

      def roles_of(actor_or_designator, resource)
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

        roles = []

        resource.acl.each do |designator, role|
          if designators.include?(designator)
            roles << role
          end
        end

        roles
      end



      ##
      # The permissions defined for each role.
      #
      # @return [Hash] the defined permissions, keyed by +role+
      #
      # @see DSL::Resource::Permissions
      #
      def permissions
      end

      # The defined roles.
      #
      # @return [Array]
      #
      # @see DSL::Resource
      #
      def roles
      end

      # Roles' priority map keyed by role symbol.
      #
      # @return [Hash]
      #
      # @see DSL::Resource
      #
      def roles_priority
      end

      # Role labels map keyed by role symbol
      #
      # @return [Hash]
      #
      # @see DSL::Resource
      #
      def roles_with_labels
      end
    end

    ##
    # @return [Boolean] whether the given +action+ is allowed to the given +actor+.
    #
    # @param action [Symbol]
    # @param actor [Actor]
    #
    def allows?(action, actor)
      self.class.allows?(action, actor, self)
    end

    ##
    # @return [Symbol] the role of the given +actor+
    #
    # @param actor [Actor]
    #
    def role_of(actor)
      self.class.role_of(actor, self)
    end

    ##
    # Grants the given +designator+ access to this Resource as the given +role+.
    #
    # @param role [Symbol]
    # @param designator [Variadic], see {ACL#add}
    #
    # @return [ACL]
    #
    # @see #change_acl
    #
    def grant(role, *designator)
      self.check_role!(role)

      change_acl {|acl| acl.add(role, *designator) }
    end

    ##
    # Revokes the given +designator+ access to this Resource.
    #
    # @param designator [Variadic], see {ACL#del}
    #
    # @return [ACL]
    #
    # @see #change_acl
    #
    def revoke(*designator)
      change_acl {|acl| acl.del(*designator) }
    end

    # Grants the given set of +designators+ access as to this Resource as the
    # given +role+.
    #
    # @param role [Symbol]
    # @param designators [Array] of {Designator}, see {ACL#add}
    #
    # @return [ACL]
    #
    # @see #change_acl
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
      ##
      # Changes the ACL, calling the persistance setter if it changes.
      #
      # @yield [ACL] the current ACL or a new one if no ACL is set
      #
      # @return [ACL] the new ACL
      #
      def change_acl
        acl = yield self.acl.try(:dup) || self.class.acl.new

        self.acl = acl unless acl == self.acl

        return self.acl
      end

      ##
      # Checks whether the given +role+ is valid for this Resource.
      #
      # @param role [Symbol] the role name.
      #
      # @raise [Eaco::Error] if not valid.
      #
      def check_role!(role)
        unless self.class.role?(role)
          raise Error,
            "The `#{role}' role is not valid for `#{self.class.name}' objects. " \
            "Valid roles are: `#{self.class.roles.join(', ')}'"
        end
      end
  end

end
