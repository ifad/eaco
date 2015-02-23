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
      end

    end
  end
end
