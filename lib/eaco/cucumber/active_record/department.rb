module Eaco
  module Cucumber
    module ActiveRecord

      ##
      # A department holds many {Position}s.
      #
      # For the background story, see {Eaco::Cucumber::World}.
      #
      # @see Position
      # @see Eaco::Actor
      # @see Eaco::Cucumber::World
      #
      class Department < ::ActiveRecord::Base
        has_many :positions
        has_many :users, through: :positions

        validates :name, uniqueness: true
      end

    end
  end
end
