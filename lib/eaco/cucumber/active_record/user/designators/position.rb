module Eaco
  module Cucumber
    module ActiveRecord
      class User
        module Designators

          ##
          # A {Designator} based on a position an {User} occupies in an
          # organigram. It resolves {Actor}s by id looking them up from
          # the +user_id+ field.
          #
          # The Position ID is available as the {Designator#value}.
          #
          # The String representation for an example Position 42 is
          # +"position:42"+.
          #
          class Position < Eaco::Designator
            ##
            # This {Designator} description.
            #
            # @return [String] the {Position} name, such as "Manager" or
            #                  or "Systems Analyst" or "Consultant".
            #
            def describe(*)
              "#{position.name} in #{position.department.name}"
            end

            ##
            # {User}s matching this designator.
            #
            # @return [Array] the user currently occupying this Position.
            #
            def resolve
              [position.user]
            end

            private
              ##
              # Looks up this position by ID, and memoizes it in an instance
              # variable.
              #
              # @return [ActiveRecord::Position] the referenced Position.
              #
              def position
                @_position ||= ActiveRecord::Position.find(self.value)
              end
          end

        end
      end
    end
  end
end
