module Eaco
  module DSL

    # Base DSL class, provides the target class, the given options, and a
    # `target_eval` helper to do instance_eval on the target.
    #
    # Nothing fancy.
    #
    class Base

      # Executes a DSL block in the context of a DSL manipulator.
      #
      # See derived classes for details.
      #
      def self.eval(klass, options = {}, &block)
        new(klass, options).tap do |dsl|
          dsl.instance_eval(&block) if block
        end
      end

      # The target class of the manipulation, and dsl-specifi options.
      attr_reader :target, :options

      def initialize(target, options) # :nodoc:
        @target, @options = target, options
      end

      protected
        # Evaluates the given block in the context of the target class that is
        # being manipulated.
        #
        def target_eval(&block)
          target.instance_eval(&block)
        end
    end

  end
end
