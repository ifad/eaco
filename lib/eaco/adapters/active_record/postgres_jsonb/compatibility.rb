module Eaco
  module Adapters
    module ActiveRecord
      module PostgresJSONb
        class Compatibility < Eaco::Adapters::ActiveRecord::Compatibility
          autoload :V32, 'eaco/adapters/active_record/postgres_jsonb/compatibility/v32.rb'
          autoload :V40, 'eaco/adapters/active_record/postgres_jsonb/compatibility/v40.rb'
          autoload :V41, 'eaco/adapters/active_record/postgres_jsonb/compatibility/v41.rb'
          autoload :V42, 'eaco/adapters/active_record/postgres_jsonb/compatibility/v42.rb'
          autoload :V50, 'eaco/adapters/active_record/postgres_jsonb/compatibility/v50.rb'
        end
      end
    end
  end
end
