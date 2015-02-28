module Eaco
  module Adapters

    ##
    # CouchRest::Model backing store for ACLs, that naively uses +property+.
    # As the ACL class is an +Hash+, it gets unserialized automagically by
    # CouchRest guts.
    #
    # @see ACL
    # @see CouchDBLucene
    #
    # :nocov: because there are too many moving parts here and anyway we are
    # going to deprecate this in favour of jsonb
    module CouchrestModel
      autoload :CouchDBLucene, 'eaco/adapters/couchrest_model/couchdb_lucene'

      ##
      # Returns currently available collection extraction strategies.
      #
      def self.strategies
        {lucene: CouchDBLucene}
      end

      ##
      # Defines the +acl+ property on the given model
      #
      # @param base [CouchRest::Model] your model class.
      #
      # @return [void]
      #
      def self.included(base)
        base.instance_eval do
          property :acl, acl
        end
      end
    end
    # :nocov:

  end
end
