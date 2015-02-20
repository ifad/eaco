module Eaco

  module DSL
    autoload :Base,     'eaco/dsl/base'

    autoload :ACL,      'eaco/dsl/acl'
    autoload :Actor,    'eaco/dsl/actor'
    autoload :Resource, 'eaco/dsl/resource'

    extend self

    def authorize(klass, options = {}, &block)
      DSL::Resource.eval(klass, options, &block)
      DSL::ACL.eval(klass)
    end

    def actor(klass, options = {}, &block)
      DSL::Actor.eval(klass, options, &block)
    end
  end

end
