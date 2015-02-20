module Eaco
  module DSL

    class Actor < Base
      def designators(&block)
        target = @target
        self.class.instance_eval do
          @designators ||= Designators.eval(target, &block)
        end
      end

      def admin(&block)
        self.class.instance_eval do
          @admin_logic = block
        end
      end

      class << self
        attr_reader :designators, :admin_logic
      end

      class Designators
        def self.eval(klass, &block)
          collector = new(klass).tap { |design| design.instance_eval(&block) }
          collector.designators.freeze
        end

        attr_reader :designators

        def initialize(target)
          @target = target
          @designators = {}
        end

        private
          def define_designator(name, options)
            root = @target.const_get(:Designators)
            unless root.parent == @target
              raise NameError, "undefined constant #@target::Designators"
            end

            designators[name] = root.
              const_get(name.to_s.camelize.intern).
              configure!(options)
          rescue => e
            raise Error, "Invalid designator definition: #{e.message}"
          end

          def method_missing(method, *args, &block)
            define_designator(method, *args, &block)
          end
      end

      module ClassMethods
        def is_admin?(user)
          instance_exec(user, &Actor.admin_logic)
        end

        def designators
          Actor.designators
        end

        def designators_for(user)
          Set.new.tap do |ret|
            designators.each do |_, designator|
              ret.merge designator.eval(user)
            end
          end
        end
      end

      module InstanceMethods
        def designators
          @_designators ||= self.class.designators_for(self)
        end

        def is_admin?
          self.class.is_admin?(self)
        end

        def can?(action, target)
          target.allows?(action, self)
        end
      end
    end

  end
end
