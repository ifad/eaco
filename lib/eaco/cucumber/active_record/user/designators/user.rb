module Eaco
  module Cucumber
    module ActiveRecord
      class User
        module Designators

          ##
          # The simplest {Designator}. It resolves actors by their unique ID,
          # such as an autoincrementing ID in a relational database.
          #
          # The ID is available as the {Designator#value}. If the Designator
          # is instantiated with a live instance (see {Designator#initialize})
          # then it is re-used and a query to the database is avoided.
          #
          # The designator string representation for user 42 is +"user:42"+.
          #
          class User < Eaco::Designator
            ##
            # @return [String] the {User}'s name.
            #
            def describe(*)
              "User '%s'" % [target_user.name]
            end

            ##
            # @return [Array] this very {User} wrapped in an +Array+.
            #
            def resolve
              [target_user]
            end

            private
              ##
              # Looks up this user by ID, and memoizes it using the
              # {Designator#instance=} accessor.
              #
              # @return [User] this very user.
              #
              def target_user
                self.instance ||= ActiveRecord::User.find(self.value)
              end
          end

        end
      end
    end
  end
end
