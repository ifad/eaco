module Eaco
  module Cucumber
    module ActiveRecord
      class User
        module Designators

          ##
          # A {Designator} based on a the {User} class.
          #
          # This is an example on how to grant rights to all instances
          # of a given model.
          #
          # The class name is available as the {Designator#value}.
          #
          # The String representation for an example User is
          # +"authenticated:User"+.
          #
          class Authenticated < Eaco::Designator
            ##
            # This {Designator} description.
            #
            # @return [String] an hardcoded description
            #
            def describe(*)
              "Any authenticated user"
            end

            ##
            # {User}s matching this designator.
            #
            # @return [Array] All {User}s.
            #
            def resolve
              klass.all
            end

            private
              ##
              # Looks up this class by constantizing it.
              #
              # @return [Class]
              #
              def klass
                @_klass ||= self.value.constantize
              end
          end

        end
      end
    end
  end
end
