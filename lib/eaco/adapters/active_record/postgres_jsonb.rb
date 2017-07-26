module Eaco
  module Adapters
    module ActiveRecord

      ##
      # Authorized collection extractor on PostgreSQL >= 9.4 and a +jsonb+
      # column named +acl+.
      #
      # TODO negative authorizations (using a separate column?)
      #
      # @see ACL
      # @see Actor
      # @see Resource
      #
      module PostgresJSONb
        autoload :Compatibility, 'eaco/adapters/active_record/postgres_jsonb/compatibility'

        ##
        # Uses the json key existance operator +?|+ to check whether one of the
        # +Actor+'s +Designator+ instances exist as keys in the +ACL+ objects.
        #
        # @param actor [Actor]
        #
        # @return [ActiveRecord::Relation] the authorized collection scope.
        #
        def accessible_by(actor)
          return scoped if actor.is_admin?

          designators = actor.designators.map {|d| sanitize(d) }

          column = "#{connection.quote_table_name(table_name)}.acl"

          where("#{column} ?| array[#{designators.join(',')}]::varchar[]")
        end

        ##
        # Checks whether the model's AR version is supported and the ACL
        # data structure fulfills the ACL persistance requirements.
        #
        def self.validate!(model)
          Compatibility.new(model).check!

          return unless model.table_exists?

          column = model.columns_hash.fetch('acl', nil)

          unless column
            raise Malformed, "Please define a jsonb column named `acl` on #{model}."
          end

          unless column.type == required_column_type
            raise Malformed, "The `acl` column on #{model} must be of the jsonb type - found: #{column.type}."
          end
        end

        def self.required_column_type
          :jsonb
        end
      end

    end
  end
end
