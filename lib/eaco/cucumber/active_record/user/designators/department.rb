module Eaco
  module Cucumber
    module ActiveRecord
      class User
        module Designators

          ##
          # A {Designator} based on a the {Department} an {User} occupies
          # a {Position} in. It resolves {Actor}s by id looking them up
          # through the {Position} model.
          #
          # As {Department}s have unique names, their name instead of
          # their ID is used in this example.
          #
          # The Department name is available as the {Designator#value}.
          #
          # The String representation for an example ICT Department is
          # +"department:ICT"+.
          #
          class Department < Eaco::Designator
            ##
            # This {Designator} description.
            #
            # @return [String] the {Department} name, such as ICT or COM
            #                  or EXE or BAT.
            #
            def describe(*)
              department.name
            end

            ##
            # {User}s matching this designator.
            #
            # @return [Array] all users currently occupying a position in
            #                 this Department
            #
            def resolve
              department.users
            end

            private
              ##
              # Looks up this Department by name, and memoizes it in an
              # instance variable.
              #
              # @return [ActiveRecord::Department] the referenced department
              #
              def department
                @_department ||= ActiveRecord::Department.
                  where(name: self.value).first!
              end
          end

        end
      end
    end
  end
end
