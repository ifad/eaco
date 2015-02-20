module Eaco
  module DSL

    class Base
      def self.eval(klass, options = {}, &block)
        new(klass, options).tap do |dsl|
          dsl.instance_eval(&block) if block
        end
      end

      attr_reader :target, :options

      def initialize(target, options)
        @target, @options = target, options
      end

      protected
        def target_eval(&block)
          target.instance_eval(&block)
        end
    end

  end
end
