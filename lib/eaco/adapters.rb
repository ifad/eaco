module Eaco

  # Persistance adapters for ACL objects and authorized collections extractor
  # strategies.
  #
  # @see ActiveRecord
  # @see CouchrestModel
  #
  module Adapters
    autoload :ActiveRecord,   'eaco/adapters/active_record'
    autoload :CouchrestModel, 'eaco/adapters/couchrest_model'
  end

end
