module Eaco
  module Cucumber
    module ActiveRecord

      ##
      # A Position is occupied by an {User} in a {Department}.
      #
      # For the background story, see {Eaco::Cucumber::World}.
      #
      # @see User
      # @see Department
      # @see Eaco::Cucumber::World
      #
      class Position < ::ActiveRecord::Base
        belongs_to :user
        belongs_to :department
      end

    end
  end
end
