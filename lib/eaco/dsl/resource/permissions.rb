module Eaco
  module DSL
    class Resource < Base

      ##
      # Permission collector, based on +method_missing+.
      #
      # Example:
      #
      #   1 authorize Foobar do
      #   2   permissions do
      #   3     reader :read_foo, :read_bar
      #   4     editor reader, :edit_foo, :edit_bar
      #   5     owner  editor, :destroy
      #   6   end
      #   7 end
      #
      # Within the block, each undefined method call defines a new
      # method that returns the given arguments.
      #
      # After evaluating line 3 above:
      #
      #   >> reader
      #   => #<Set{ :read_foo, :read_bar }>
      #
      # The method is used then on line 4, giving the +editor+ role the
      # same set of permissions granted to the +reader+, plus its own
      # set of permissions:
      #
      #   >> editor
      #   => #<Set{ :read_foo, :read_bar, :edit_foo, :edit_bar }>
      #
      class Permissions < Base

        ##
        # Evaluates the given block in the context of a new collector
        #
        # Returns an Hash of permissions, keyed by role.
        #
        #   >> Permissions.eval do
        #    |   permissions do
        #    |     reader :read
        #    |     editor reader, :edit
        #    |   end
        #    | end
        #
        #   => {
        #    |   reader: #<Set{ :read },
        #    |   editor: #<Set{ :read, :edit }
        #    | }
        #
        # @return [Permissions]
        #
        def self.eval(*, &block)
          super
        end

        ##
        # Sets up an hash with a default value of a new Set.
        #
        def initialize(*)
          super

          @permissions = Hash.new {|hsh, key| hsh[key] = Set.new}
        end

        ##
        # Returns the collected permissions in a plain Hash, lacking the
        # default block used by the collector's internals - to give to
        # the outside an Hash with a predictable behaviour :-).
        #
        # @return [Hash]
        #
        def result
          Hash.new.merge(@permissions)
        end

        private
          ##
          # Here the method name is the role code. If we already have defined
          # permissions for the given role, those are returned.
          #
          # Else, save_permission is called to memoize the given permissions
          # for the role.
          #
          # @return [Set]
          #
          def method_missing(role, *permissions)
            if @permissions.key?(role)
              @permissions[role]
            else
              save_permission(role, permissions)
            end
          end

          ##
          # Memoizes the given set of permissions for the given role.
          #
          # @return [Set]
          #
          # @raise [Malformed] if the syntax is not valid.
          #
          def save_permission(role, permissions)
            permissions = permissions.inject(Set.new) do |set, perm|
              if perm.is_a?(Symbol)
                set.add perm

              elsif perm.is_a?(Set)
                set.merge perm

              else
                raise Malformed, <<-EOF
                  Invalid #{role} permission definition: #{perm.inspect}.
                  Permissions can be defined only by plain symbols.
                EOF
              end
            end

            @permissions[role].merge(permissions)
          end
      end

    end
  end
end
