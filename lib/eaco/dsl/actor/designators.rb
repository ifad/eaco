module Eaco
  module DSL
    class Actor < Base

      ##
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
      # and to implement within it a +class Authenticated < Eaco::Designator+
      #
      # @see Designator
      #
      class Designators < Base
        ##
        # Sets up the designators registry.
        #
        def initialize(*)
          super

          @designators = {}
        end

        ##
        # The parsed designators, keyed by type symbol and with concrete
        # implementations as values.
        #
        # @return [Hash]
        #
        attr_reader :designators
        alias result designators

        private
          ##
          # Looks up the implementation for the designator of the given
          # +name+, configures it with the given +options+ and saves it in
          # the designators registry.
          #
          # @param name [Symbol]
          # @param options [Hash]
          #
          # @return [Class]
          #
          # @see #implementation_for
          #
          def define_designator(name, options)
            designators[name] = implementation_for(name).configure!(options)
          end
          alias method_missing define_designator

          ##
          # Looks up the +name+ designator implementation in the {Actor}'s
          # +Designators+ namespace.
          #
          # @param name [Symbol]
          #
          # @return [Class]
          #
          # @raise [Malformed] if the implementation class is not found.
          #
          # @see #container
          # @see Designator.type
          #
          def implementation_for(name)
            impl = name.to_s.camelize.intern

            unless container.const_defined?(impl)
              raise Malformed, <<-EOF
                Implementation #{container}::#{impl} for Designator #{name} not found.
              EOF
            end

            container.const_get(impl)
          end

          ##
          # Looks up the +Designators+ namespace within the {Actor}'s class.
          #
          # @return [Class]
          #
          # @raise Malformed if the +Designators+ module cannot be found.
          #
          # @see #implementation_for
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
