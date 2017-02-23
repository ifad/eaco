module Eaco
  module Adapters
    module ActiveRecord
      class Compatibility

        module V40
          def self.included(base)
            base.extend Scoped
          end
        end

      end
    end
  end
end
