module Eaco
  module Cucumber
    module ActiveRecord
      class User

        ##
        # The example {Designator}s for the {User} class.
        #
        # @see World
        #
        module Designators
          autoload :User, 'eaco/cucumber/active_record/user/designators/user.rb'
        end

      end
    end
  end
end
