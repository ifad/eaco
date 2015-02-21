module Eaco
  module Adapters

    # CouchRest::Model backing store for ACLs, that naively uses
    # `property`. As the ACL class is an Hash, it gets unserialized
    # automagically.
    #
    module CouchrestModel
      autoload :CouchDBLucene, 'eaco/adapters/couchrest_model/couchdb_lucene'

      def self.strategies # :nodoc:
        {lucene: CouchDBLucene}
      end

      def self.included(base) # :nodoc:
        base.instance_eval do
          property :acl, acl
        end
      end
    end

  end
end
