module Eaco
  module Adapters
    module ActiveRecord
      class Compatibility

        ##
        # Active Record 7.0 and up support module.
        #
        # From 5.2 through the current releases the story is unchanged: JSONB
        # works natively, while +.scoped+ and +sanitize+ stay removed and are
        # revived through the {Scoped} and {Sanitized} support modules.
        #
        # This module is the fallback for every Active Record major >= 7, so a
        # new identical +Vxx+ module is no longer needed on each Rails release.
        #
        # @see Scoped
        # @see Sanitized
        #
        module Modern
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
