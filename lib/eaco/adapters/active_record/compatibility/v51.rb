module Eaco
  module Adapters
    module ActiveRecord
      class Compatibility

        ##
        # Rails 5.1 support module.
        #
        # JSONB works correctly, but we need +.scoped+ so we revive it through
        # the {Scoped} support module.
        #
        # Sanitize has dissapeared in favour of quote.
        #
        # @see Scoped
        #
        module V51
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
