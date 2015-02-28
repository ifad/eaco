module Eaco
  module Adapters
    module CouchrestModel

      ##
      # Authorized collection extractor on CouchDB using the CouchDB Lucene
      # full-text indexer <https://github.com/ifad/couchdb-lucene>, a patched
      # CouchRest <https://github.com/ifad/couchrest> to interact with the
      # "_fti" couchdb lucene API endpoint, and a patched CouchRest::Model
      # <https://github.com/ifad/couchrest_model> that provides a search()
      # API to run lucene queries.
      #
      # It requires an indexing strategy similar to the following:
      #
      #   {
      #     _id: "_design/lucene",
      #     language: "javascript",
      #     fulltext: {
      #       search: {
      #         defaults: { store: "no" },
      #         analyzer: "perfield:{acl:\"keyword\"}",
      #         index: function(doc) {
      #
      #           var acl = doc.acl;
      #           if (!acl) {
      #             return null;
      #           }
      #
      #           var ret = new Document();
      #
      #           for (key in acl) {
      #             ret.add(key, {
      #               type: 'string',
      #               field: 'acl',
      #               index: 'not_analyzed'
      #             });
      #           }
      #
      #           return ret;
      #         }
      #       }
      #     }
      #   }
      #
      # Made in Italy.
      #
      # @see ACL
      # @see Actor
      # @see Resource
      #
      # :nocov: because there are too many moving parts here and anyway we are
      # going to deprecate this in favour of jsonb
      module CouchDBLucene

        ##
        # Uses a Lucene query to extract Resources accessible by the given Actor.
        #
        # @param actor [Actor]
        #
        # @return [CouchRest::Model::Search::View] the authorized collection scope.
        #
        def accessible_by(actor)
          return search(nil) if actor.is_admin?

          designators = actor.designators.map {|item| '"%s"' % item }

          search "acl:(#{designators.join(' OR ')})"
        end
      end
      # :nocov:

    end
  end
end
