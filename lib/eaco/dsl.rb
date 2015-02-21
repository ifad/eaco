module Eaco

  # Eaco DSL namespace
  #
  module DSL
    extend self # Oh the irony.

    autoload :Base,     'eaco/dsl/base'

    autoload :ACL,      'eaco/dsl/acl'
    autoload :Actor,    'eaco/dsl/actor'
    autoload :Resource, 'eaco/dsl/resource'

    # Entry point for the Resource authorization definition.
    #
    # See +Eaco::DSL::Resource+ and +Eaco::DSL::ACL+ for details.
    #
    def authorize(resource_class, options = {}, &block)
      DSL::Resource.eval(resource_class, options, &block)
      DSL::ACL.eval(resource_class, options)
    end

    # Entry point for the Actor designators definition.
    #
    # See +Eaco::DSL::Actor+ for details.
    #
    def actor(actor_class, options = {}, &block)
      DSL::Actor.eval(actor_class, options, &block)
    end
  end

end
