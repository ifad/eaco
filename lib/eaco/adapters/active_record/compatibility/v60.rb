module Eaco
  module Adapters
    module ActiveRecord
      class Compatibility

        ##
        # Rails 6.0 support module.
        #
        # JSONB works correctly, but we need +.scoped+ so we revive it through
        # the {Scoped} support module.
        #
        # @see Scoped
        #
        # Sanitize has disappeared in favour of quote.
        #
        # @see Sanitized
        #
        module V60
          extend ActiveSupport::Concern

          included do
            extend Scoped
            extend Sanitized
          end
        end

      end
    end
  end
end
