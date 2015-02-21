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

          designators = actor.designators.map {|d| quote_value(d) }

          where("acl ?| array[#{designators.join(',')}]")
        end
      end

    end
  end
end
