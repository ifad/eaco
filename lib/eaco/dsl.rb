require 'eaco/dsl/resource'
require 'eaco/dsl/actor'

module Eaco

  module DSL
    def self.authorize(klass, options = {}, &block)
      DSL::Resource.eval(klass, options, &block)
    end

    def self.actor(klass, options = {}, &block)
      DSL::Actor.eval(klass, options, &block)
    end
  end

end
