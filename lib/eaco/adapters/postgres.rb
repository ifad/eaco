module Eaco
  module Adapters

    module Postgres
      # Requires Postgres 9.4 and a jsonb column named `acl`.
      #
      def accessible_by(user)
       designators = user.designators.map {|d| quote_value(d) }

       where("acl ?| array[#{designators.join(',')}]")
      end
    end

  end
end
