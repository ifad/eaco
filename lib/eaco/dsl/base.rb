module Eaco
  module DSL

    class Base
      def self.eval(klass, options = {}, &block)
        new(klass, options).tap { |b| b.instance_eval(&block) }
      end

      def initialize(target, options)
        @target = target
        @options = options

        if mod = module_get(:ClassMethods)
          @target.extend mod
        end

        if mod = module_get(:InstanceMethods)
          target_eval { include mod }
        end
      end

      protected
        def target_eval(&block)
          @target.instance_eval(&block)
        end

      private
        def module_get(name)
          if self.class.const_defined?(name)
            self.class.const_get(name)
          end
        end
    end

  end
end
