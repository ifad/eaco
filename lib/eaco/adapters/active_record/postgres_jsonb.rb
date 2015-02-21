module Eaco
  module Adapters
    module ActiveRecord

      # Authorized collection extractor on PostgreSQL >= 9.4 and a jsonb column
      # named `acl`.
      #
      # Uses the json key existance operator "?|" to check whether one of the
      # +Actor+'s +Designator+ instances exist as keys in the ACL objects.
      #
      # TODO negative authorizations (using a separate column?)
      #
      module PostgresJSONb

        # Returns authorized Resource objects accessible by the given Actor.
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
