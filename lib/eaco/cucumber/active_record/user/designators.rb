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
          autoload :Authenticated, 'eaco/cucumber/active_record/user/designators/authenticated.rb'
          autoload :Department,    'eaco/cucumber/active_record/user/designators/department.rb'
          autoload :Position,      'eaco/cucumber/active_record/user/designators/position.rb'
          autoload :User,          'eaco/cucumber/active_record/user/designators/user.rb'
        end

      end
    end
  end
end
