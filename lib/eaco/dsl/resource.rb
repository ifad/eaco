module Eaco
  module DSL

    # Parses the Resource definition DSL.
    #
    # Example:
    #
    #     authorize Document do
    #       roles :owner, :editor, :reader
    #
    #       role :owner, 'Author'
    #
    #       permissions do
    #         reader   :read
    #         editor   reader, :edit
    #         owner    editor, :destroy
    #       end
    #     end
    #
    # The DSL installs authorization in the Document model,
    # defining three access roles. The `owner` role is given
    # a label of "Author".
    #
    # Each role has then different abilities, defined in the
    # permissions block. See +Eaco::DSL::Resource::Permissions+
    # for details.
    #
    class Resource < Base
      autoload :Permissions, 'eaco/dsl/resource/permissions'

      # Sets up an authorized resource. The only required API
      # is `accessible_by`. For available implementations, see
      # the +Adapters+ module.
      #
      def initialize(*)
        super

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
          @_permissions = Permissions.eval(self, &block).result.freeze
        end
      end

      # Defines the roles valid for this resource. e.g.
      #
      #     authorize Foobar do
      #       roles :owner, :editor, :reader
      #     end
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
      # TODO rename this method, or use it to pass options
      # to improve readability of the DSL and to store more
      # metadata with each role for future extensibility.
      #
      def role(role, label)
        target_eval do
          roles_with_labels[role] = label
        end
      end
    end

  end
end
