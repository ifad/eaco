module Eaco

  ##
  # Eaco DSL entry point.
  #
  # @see DSL::Resource
  # @see DSL::Actor
  # @see DSL::ACL
  #
  module DSL
    extend self # Oh the irony.

    autoload :Base,     'eaco/dsl/base'

    autoload :ACL,      'eaco/dsl/acl'
    autoload :Actor,    'eaco/dsl/actor'
    autoload :Resource, 'eaco/dsl/resource'

    ##
    # Entry point for the {Resource} authorization definition.
    #
    # @see DSL::Resource
    # @see DSL::ACL
    #
    def authorize(resource_class, options = {}, &block)
      DSL::Resource.eval(resource_class, options, &block)
      DSL::ACL.eval(resource_class, options)
    end

    ##
    # Entry point for the {Actor} designators definition.
    #
    # @see DSL::Actor
    #
    def actor(actor_class, options = {}, &block)
      DSL::Actor.eval(actor_class, options, &block)
    end
  end

end
