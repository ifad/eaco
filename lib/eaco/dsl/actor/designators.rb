module Eaco
  module DSL
    class Actor

      # Designators collector using +method_missing+.
      #
      # Parses the following DSL:
      #
      #  actor User do
      #    designators do
      #      authenticated from: :class
      #      user          from: :id
      #      group         from: :group_ids
      #    end
      # end
      #
      class Designators
        def self.eval(klass, &block)
          new(klass).tap {|design| design.instance_eval(&block) }.designators
        end

        attr_reader :target, :designators

        def initialize(target)
          @target      = target
          @designators = {}
        end

        private
          # Looks up the implementation for the designator of the given
          # +name+, configures it with the given +options+ and saves it in
          # the designators map.
          def define_designator(name, options)
            designators[name] = implementation_for(name).configure!(options)
          end
          alias method_missing define_designator

          def implementation_for(name)
            impl = name.to_s.camelize.intern

            unless container.const_defined?(impl)
              raise NameError, "Implementation #{container}::#{impl} for designator #{name} not found"
            end

            container.const_get(impl)
          end

          def container
            @_container ||= begin
              unless target.const_defined?(:Designators)
                raise NameError, "Please put designators implementations in #{target}::Designators"
              end

              target.const_get(:Designators)
            end
          end
      end

    end
  end
end
