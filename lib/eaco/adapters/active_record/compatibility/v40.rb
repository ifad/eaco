module Eaco
  module Adapters
    module ActiveRecord
      class Compatibility

        ##
        # Rails v4.0.X compatibility layer for jsonb
        #
        module V40
          ##
          #
          # Sets up the OID Type Map, reloads it, hacks native database types,
          # and makes jsonb mimick itself as a json - for the rest of the AR
          # machinery to work intact.
          #
          # @param base [Class] the +ActiveRecord+ model to mangle
          # @return [void]
          #
          def self.included(base)
            adapter = base.connection

            adapter.class::OID.register_type 'jsonb', adapter.class::OID::Json.new
            adapter.send :reload_type_map

            adapter.native_database_types.update(jsonb: {name: 'jsonb'})

            adapter.class.parent::PostgreSQLColumn.instance_eval do
              include Column
            end
          end

          ##
          # Patches to ActiveRecord::ConnectionAdapters::PostgreSQLColumn
          #
          module Column
            ##
            # Makes +sql_type+ return +json+ for +jsonb+ columns. This is
            # an hack to let the casting machinery in AR 4.0 keep working
            # with the unsupported +jsonb+ type.
            #
            # @return [String] the SQL type.
            #
            def sql_type
              orig_type = super
              orig_type == 'jsonb' ? 'json' : orig_type
            end

            ##
            # Makes +simplified_type+ return +json+ for +jsonb+ columns
            #
            # @param field_type [String] the database field type
            # @return [Symbol] the simplified type
            #
            def simplified_type(field_type)
              if field_type == 'jsonb'
                :json
              else
                super
              end
            end
          end
        end

      end
    end
  end
end
