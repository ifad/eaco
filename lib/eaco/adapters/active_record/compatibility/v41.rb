module Eaco
  module Adapters
    module ActiveRecord
      class Compatibility

        ##
        # Rails 4.1 support module - same as 4.0.
        #
        # @see V40
        #
        module V41
          extend ActiveSupport::Concern

          included do
            include V40
          end
        end

      end
    end
  end
end
