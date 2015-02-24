module Eaco
  module Adapters
    module ActiveRecord
      class Compatibility

        ##
        # Rails 3.2 JSONB support module.
        #
        # Uses https://github.com/romanbsd/activerecord-postgres-json to do
        # the dirty compatibility stuff.
        #
        module V32
          require 'activerecord-postgres-json'
        end

      end
    end
  end
end
