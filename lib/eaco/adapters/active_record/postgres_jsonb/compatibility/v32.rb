module Eaco
  module Adapters
    module ActiveRecord
      module PostgresJSONb
        class Compatibility

          ##
          # Rails 3.2 JSONB support module.
          #
          # Uses https://github.com/romanbsd/activerecord-postgres-json to do
          # the dirty compatibility stuff. This module only uses +.serialize+
          # to set the +JSON+ coder.
          #
          module V32
            require 'activerecord-postgres-json'

            ##
            # Sets the JSON coder on the acl column
            #
            def self.included(base)
              base.serialize :acl, ::ActiveRecord::Coders::JSON
            end
          end

        end
      end
    end
  end
end
