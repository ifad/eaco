module Eaco
  module Adapters
    module ActiveRecord
      class Compatibility

        ##
        # Rails 4.1 support module.
        #
        # Magically, the 4.0 hacks work on 4.1. But on 4.1 we need the
        # +.scoped+ API so we revive it through the {Scoped} module.
        #
        # @see V40
        # @see Scoped
        #
        module V41
          extend ActiveSupport::Concern

          included do
            include V40
            extend Scoped
          end
        end

      end
    end
  end
end
