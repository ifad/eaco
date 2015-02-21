module Eaco
  module DSL

    ##
    # Base DSL class. Provides handy access to the +target+ class being
    # manipulated, DSL-specific options, and a {#target_eval} helper to do
    # +instance_eval+ on the +target+.
    #
    # Nothing too fancy.
    #
    class Base

      ##
      # Executes a DSL block in the context of a DSL manipulator.
      #
      # @see DSL::ACL
      # @see DSL::Actor
      # @see DSL::Resource
      #
      # @return [Base]
      #
      def self.eval(klass, options = {}, &block)
        new(klass, options).tap do |dsl|
          dsl.instance_eval(&block) if block
        end
      end

      # The target class of the manipulation
      attr_reader :target

      # DSL-specific options
      attr_reader :options

      ##
      # @param target [Class]
      # @param options [Hash]
      #
      def initialize(target, options)
        @target, @options = target, options
      end

      protected
        ##
        # Evaluates the given block in the context of the target class
        #
        def target_eval(&block)
          target.instance_eval(&block)
        end
    end

  end
end
