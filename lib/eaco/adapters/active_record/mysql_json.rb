module Eaco
  module Adapters
    module ActiveRecord

      ##
      # Authorized collection extractor on MySQL >= 5.7 and a +json+
      # column named +acl+.
      #
      # TODO negative authorizations (using a separate column?)
      #
      # @see ACL
      # @see Actor
      # @see Resource
      #
      module MySQLJSON

        ##
        # Uses +JSON_CONTAINS_PATH()+ to check whether one of the +Actor+'s
        # +Designator+ instances exist as keys in the +ACL+ object.
        #
        # @param actor [Actor]
        #
        # @return [ActiveRecord::Relation] the authorized collection scope.
        #
        def accessible_by(actor)
          return scoped if actor.is_admin?

          designators = actor.designators.map {|d| sanitize("$.#{d}") }

          column = "#{connection.quote_table_name(table_name)}.acl"

          where("JSON_CONTAINS_PATH(#{column}, 'one', #{designators.join(',')})")
        end

        ##
        # Checks whether the model's data structure fulfills
        # the ACL persistance requirements.
        #
        def self.validate!(model)
          return unless model.table_exists?

          column = model.columns_hash.fetch('acl', nil)

          unless column
            raise Malformed, "Please define a json column named `acl` on #{model}."
          end

          unless column.type == required_column_type
            raise Malformed, "The `acl` column on #{model} must be of the JSON type - found: #{column.type}."
          end
        end

        def self.required_column_type
          :json
        end
      end

    end
  end
end
