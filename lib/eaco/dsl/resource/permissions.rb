module Eaco
  module DSL
    class Resource

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
      # method that returns the given arguments. E.g. on line 4 above
      # the `reader` call then defines the `reader` method that returns
      # a #<Set: {$read_foo, :read_bar}>.
      #
      # The method is used then on line 4, giving the `editor` role the
      # same set of permissions granted to the `reader`.
      #
      class Permissions
        # Evaluates the given block in the context of a new collector
        #
        # Returns a frozen Hash of permissions.
        #
        def self.eval(&block)
          new.tap {|c| c.instance_eval(&block)}.result
        end

        # Sets up an hash with a default value of a new Set.
        #
        def initialize
          @permissions = Hash.new {|hsh, key| hsh[key] = Set.new}
        end

        attr_reader :permissions

        # Returns the collected permissions in a plain hash without
        # a default block.
        #
        def result
          Hash.new.merge(@permissions)
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

    end
  end
end
