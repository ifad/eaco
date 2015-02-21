module Eaco
  module Adapters

    # PostgreSQL 9.4 and up backing store for ACLs.
    #
    module ActiveRecord
      autoload :PostgresJSONb, 'eaco/adapters/active_record/postgres_jsonb'

      def self.strategies
        {:pg_jsonb => PostgresJSONb}
      end

      def self.included(base)
        column = base.columns_hash.fetch('acl', nil)

        unless column
          raise Malformed, "Please define a jsonb column named `acl` on #{base}."
        end

        unless column.type == :json
          raise Malformed, "The `acl` column on #{base} must be of the json type."
        end
      end

      def acl
        acl = read_attribute(:acl)
        self.class.acl.new(acl)
      end

      def acl=(acl)
        write_attribute acl.to_hash
      end
    end

  end
end
