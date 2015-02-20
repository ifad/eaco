module Eaco

  module DSL
    autoload :Base,     'eaco/dsl/base'
    autoload :Actor,    'eaco/dsl/actor'
    autoload :Resource, 'eaco/dsl/resource'

    extend self

    def authorize(klass, options = {}, &block)
      DSL::Resource.eval(klass, options, &block)
    end

    def actor(klass, options = {}, &block)
      DSL::Actor.eval(klass, options, &block)
    end
  end

end
