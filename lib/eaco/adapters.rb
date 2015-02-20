module Eaco

  module Adapters
    autoload :ACL, 'eaco/adapters/acl'

    autoload :Lucene, 'eaco/adapters/lucene'
    autoload :Postgres, 'eaco/adapters/postgres'
  end

end
