module Eaco
  module Adapters

    ##
    # PostgreSQL 9.4 and up backing store for ACLs.
    #
    # @see ACL
    # @see PostgresJSONb
    #
    module ActiveRecord
      autoload :PostgresJSONb, 'eaco/adapters/active_record/postgres_jsonb'
      autoload :Compatibility, 'eaco/adapters/active_record/compatibility'

      ##
      # Currently defined collection extraction strategies.
      #
      # @return Hash
      #
      def self.strategies
        {:pg_jsonb => PostgresJSONb}
      end

      ##
      # Checks whether the model's data structure fits the ACL persistance
      # requirements.
      #
      # @param base [Class] your application's model
      #
      # @return void
      #
      def self.included(base)
        Compatibility.new(base).check!

        return unless base.table_exists?

        column = base.columns_hash.fetch('acl', nil)

        unless column
          raise Malformed, "Please define a jsonb column named `acl` on #{base}."
        end

        unless column.type == :json || column.type == :jsonb
          raise Malformed, "The `acl` column on #{base} must be of the jsonb type."
        end
      end

      ##
      # @return [ACL] this Resource's ACL.
      #
      # @see ACL
      #
      def acl
        acl = read_attribute(:acl)
        self.class.acl.new(acl)
      end

      ##
      # Sets the Resource's ACL.
      #
      # @param acl [ACL] the new ACL to set.
      #
      # @return [ACL]
      #
      # @see ACL
      #
      def acl=(acl)
        write_attribute :acl, acl.to_hash
      end
    end

  end
end
