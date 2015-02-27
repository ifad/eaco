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
    # @param resource_class [Class] the application resource class
    # @param options [Hash] options passed to {DSL::Resource} and
    #                       and {DSL::ACL}.
    #
    # @see DSL::Resource
    # @see DSL::ACL
    #
    def authorize(resource_class, options = {}, &block)
      DSL::Resource.eval(resource_class, options, &block)
      DSL::ACL.eval(resource_class, options)
    end

    ##
    # Entry point for an {Actor} definition.
    #
    # @param actor_class [Class] the application actor class
    # @param options [Hash] currently unused
    # @param block [Proc] the DSL code to eval
    #
    # @see DSL::Actor
    #
    def actor(actor_class, options = {}, &block)
      DSL::Actor.eval(actor_class, options, &block)
    end
  end

end
