module Eaco
  module Cucumber
    module ActiveRecord

      ##
      # This is an example of a {Eaco::Actor} that can be authorized against
      # the ACLs in a resource, such as the example {Document}.
      #
      # For the background story, see {Eaco::Cucumber::World}.
      #
      # @see Document
      # @see Eaco::Actor
      # @see Eaco::Cucumber::World
      #
      class User < ::ActiveRecord::Base
        autoload :Designators, 'eaco/cucumber/active_record/user/designators.rb'

        has_many :positions
        has_many :departments, through: :positions

        ##
        # The {Department} names this User has a {Position} in.
        #
        # @return [Array] the {Department} names as +String+s.
        #
        def department_names
          departments.to_set(&:name)
        end
      end

    end
  end
end
