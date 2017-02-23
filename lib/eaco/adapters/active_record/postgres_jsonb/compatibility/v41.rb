module Eaco
  module Adapters
    module ActiveRecord
      module PostgresJSONb
        class Compatibility

          ##
          # Rails 4.1 support module.
          #
          # Magically, the 4.0 hacks work on 4.1.
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
end
