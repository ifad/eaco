module Eaco
  module DSL
    class Actor

      # Designators collector using +method_missing+.
      #
      # Parses the following DSL:
      #
      #   actor User do
      #     designators do
      #       authenticated from: :class
      #       user          from: :id
      #       group         from: :group_ids
      #     end
      #   end
      #
      # and looks up within the Designators namespace of the Actor model the
      # concrete implementations of the described designators.
      #
      # Here the User model is expected to define an User::Designators module
      # and to implement within it a `class Authenticated < Eaco::Designator`
      # See +Eaco::Designator+ for details about Designators.
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
          #
          def define_designator(name, options)
            designators[name] = implementation_for(name).configure!(options)
          end
          alias method_missing define_designator

          def implementation_for(name)
            impl = name.to_s.camelize.intern

            unless container.const_defined?(impl)
              raise Malformed, <<-EOF
                Implementation #{container}::#{impl} for Designator #{name} not found
              EOF
            end

            container.const_get(impl)
          end

          # Looks up the `Designators` namepsace within the Actor's class or
          # raises if not found.
          #
          def container
            @_container ||= begin
              unless target.const_defined?(:Designators)
                raise Malformed, "Please put designators implementations in #{target}::Designators"
              end

              target.const_get(:Designators)
            end
          end
      end

    end
  end
end
