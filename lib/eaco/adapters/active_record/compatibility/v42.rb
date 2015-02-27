module Eaco
  module Adapters
    module ActiveRecord
      class Compatibility

        ##
        # Rails 4.2 support module.
        #
        # JSONB works correctly, but we need +.scoped+ so we revive it through
        # the {Scoped} support module.
        #
        # @see Scoped
        #
        module V42
          extend ActiveSupport::Concern

          included do
            extend Scoped
          end
        end

      end
    end
  end
end
