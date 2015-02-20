module Eaco
  module DSL

    class Resource < Base
      def initialize(*)
        super

        if adapter = @options.fetch(:using, nil)
          adapter = adapter.to_s.camelize
          @target.extend Eaco::Adapters.const_get(adapter)
        end

        unless @target.respond_to?(:accessible_by)
          raise Error, "To authorize #{@target} either use an adapter or define your own `accessible_by` method."
        end

        Eaco::Adapters::ACL.install(@target)
      end

      def permissions(&block)
        target_eval { @_authz_permissions = Permissions.eval(&block) }
      end

      # Set a label for the given role
      def role(role, label)
        target_eval do
          @_authz_role_labels ||= {}
          @_authz_role_labels[role] = label
        end
      end

      def roles(*roles)
        target_eval do
          @_authz_roles = roles.flatten.freeze
          @_authz_role_labels =
            (@_authz_roles.inject({}) {|h, r| h.update(r => r.to_s.humanize)}).
            merge(@_authz_role_labels || {})

          # Builds an hash from the given roles, for fast lookup of priorities
          #
          @_authz_roles_priority = {}.tap do |priorities|
            roles.each_with_index {|role, idx| priorities[role] = idx}
          end.freeze

          # Define a customized ACL
          const_get(:ACL).instance_eval do
            roles.each do |role|
              define_method(role.to_s.pluralize) { find_by_role(role) }
            end
          end
        end
      end

      # Permission collector, based on +method_missing+.
      #
      # Example:
      #
      #     permissions do
      #       reader :read_foo, :read_bar
      #       editor reader, :edit_foo, :edit_bar
      #       owner  editor, :destroy
      #     end
      #
      class Permissions
        attr_reader :permissions

        # Evaluates the given block in the context of a new collector
        #
        # Returns a frozen Hash of permissions.
        #
        def self.eval(&block)
          collector = new.tap {|c| c.instance_eval(&block)}
          # Merge into a new Hash to remove the Hash default block
          Hash.new.merge(collector.permissions).freeze
        end

        def initialize
          @permissions = Hash.new {|hsh, key| hsh[key] = Set.new}
        end

        private
          def define_permissions(role, perms)
            perms = perms.inject(Set.new) do |set, perm|
              if perm.is_a?(Symbol)
                set.add perm
              elsif perm.is_a?(Set)
                set.merge perm
              else
                raise Error, "Invalid permission definition: #{perm.inspect}"
              end
            end

            permissions[role].merge(perms)
          end

          def method_missing(method, *args, &block)
            if permissions.key?(method)
              permissions[method]
            else
              define_permissions(method, args)
            end
          end
      end

      module ClassMethods
        def roles
          @_authz_roles
        end

        def role?(role)
          role.to_sym.in?(roles)
        end

        def roles_with_labels
          @_authz_role_labels
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

          perms = @_authz_permissions[role]
          return false unless perms

          perms.include?(action)
        end

        # Returns the given user's role in the given record, or nil if no
        # access is granted.
        #
        def role_of(user_or_designator, record)
          designators = if user_or_designator.is_a?(Eaco::Designator)
            [user_or_designator]
          elsif user_or_designator.respond_to?(:designators)
            user_or_designator.designators
          else
            raise Error, "Invalid argument: #{user_or_designator.inspect}"
          end

          role_priority = nil
          record.acl.each do |designator, role|
            if designators.include?(designator)
              priority = @_authz_roles_priority[role]
            end

            if priority && (role_priority.nil? || priority < role_priority)
              role_priority = priority
              break if role_priority == 0
            end
          end

          @_authz_roles[role_priority] if role_priority
        end
      end

      module InstanceMethods
        def allows?(action, user)
          self.class.allows?(action, user, self)
        end

        def role_of(user)
          self.class.role_of(user, self)
        end

        def grant(role, *args)
          self.check_role!(role)

          acl = self.acl.try(:dup) || ACL.new
          acl.add(role, *args)

          self.acl = acl unless acl == self.acl
        end

        def revoke(*args)
          acl = self.acl.try(:dup) || ACL.new
          acl.del(*args)

          self.acl = acl unless acl == self.acl
        end

        def batch_grant(role, designators)
          self.check_role!(role)
          self.acl_will_change!

          designators.each do |designator|
            self.acl.add(role, designator)
          end
        end

        protected
          def check_role!(role)
            unless self.class.role?(role)
              raise Error, "The `#{role}' role is not valid for `#{self.class.name}' objects. Valid roles are: `#{self.class.roles.join(', ')}'"
            end
          end
      end

    end # Resource

  end
end
