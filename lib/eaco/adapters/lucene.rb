module Eaco
  module Adapters

    module Lucene
      # Returns items accessible by the given user, using
      # a Lucene query.
      #
      def accessible_by(user)
       return search(nil) if user.is_admin?

       designators = user.designators.map {|item| '"%s"' % item}

       search "acl:(#{designators.join(' OR ')})"
      end
    end

  end
end
