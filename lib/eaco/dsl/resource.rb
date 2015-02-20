module Eaco
  module DSL

    class Resource < Base
      autoload :Permissions, 'eaco/dsl/resource/permissions'

      # Sets up an authorized resource. The only required API
      # is `accessible_by`. For available implementations, see
      # the +Adapters+ module.
      #
      def initialize(*)
        super

        if adapter = options.fetch(:using, nil)
          adapter = adapter.to_s.camelize
          target.extend Eaco::Adapters.const_get(adapter)
        end

        unless target.respond_to?(:accessible_by)
          raise Error, "To authorize #{target} either use an adapter or define your own `accessible_by` method."
        end

        target_eval do
          include Eaco::Resource

          # The permissions defined for each role.
          #
          def permissions
            @_permissions
          end

          # The defined roles.
          #
          def roles
            @_roles
          end

          # Roles' priority map keyed by role symbol.
          #
          def roles_priority
            @_roles_priority ||= {}.tap do |priorities|
              roles.each_with_index {|role, idx| priorities[role] = idx }
            end.freeze
          end

          # Role labels map keyed by role symbol
          #
          def roles_with_labels
            @_roles_with_labels ||= roles.inject({}) do |labels, role|
              labels.update(role => role.to_s.humanize)
            end
          end

          # Reset memoizations when this method is called on the target class,
          # so that reloading the authorizations configuration file will
          # refresh the models' configuration.
          @_roles_priority = nil
          @_roles_with_labels = nil
        end
      end

      # Defines the permissions on this resource. The evaluated registries are
      # memoized in the target class.
      #
      def permissions(&block)
        target_eval do
          @_permissions = Permissions.eval(&block).freeze
        end
      end

      # Defines the roles valid for this resource. e.g.
      #
      # authorize Foobar do
      #   roles :owner, :editor, :reader
      # end
      #
      # Roles defined first have higher priority.
      #
      # If the same user is at the same time `reader` and `editor`, the
      # resulting role is `editor`.
      #
      def roles(*keys)
        target_eval do
          @_roles = keys.flatten.freeze
        end
      end

      # Sets the given label on the given role.
      #
      # TODO rename this method, or use it to pass options.
      #
      def role(role, label)
        target_eval do
          roles_with_labels[role] = label
        end
      end
    end

  end
end
