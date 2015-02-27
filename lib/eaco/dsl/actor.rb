module Eaco
  module DSL

    ##
    # Parses the Actor DSL, that describes how to harvest {Designator}s from
    # an {Actor} and how to identify it as an +admin+, or superuser.
    #
    #   actor User do
    #     admin do |user|
    #       user.admin?
    #     end
    #
    #     designators do
    #       authenticated from: :class
    #       user          from: :id
    #       group         from: :group_ids
    #     end
    #   end
    #
    class Actor < Base
      autoload :Designators, 'eaco/dsl/actor/designators'

      ##
      # Makes an application model a valid {Eaco::Actor}.
      #
      # @see Eaco::Actor
      #
      def initialize(*)
        super

        target_eval do
          include Eaco::Actor

          def designators
            @_designators
          end

          def admin_logic
            @_admin_logic
          end
        end
      end

      ##
      # Defines the designators that apply to this {Actor}.
      #
      # Example:
      #
      #   actor User do
      #     designators do
      #       authenticated from: :class
      #       user          from: :id
      #       group         from: :group_ids
      #     end
      #   end
      #
      # {Designator} names are collected using +method_missing+, and are
      # named after the method name. Implementations are looked up in
      # a +Designators+ module in the {Actor}'s class.
      #
      # Each designator implementation is expected to be named after the
      # designator's name, camelized, and inherit from {Eaco::Designator}.
      #
      # TODO all designators share the same namespace. This is due to the
      # fact that designator string representations aren't scoped by the
      # Actor model they belong to. As such when instantiating a designator
      # from +Eaco::Designator.make+ the registry is consulted to find the
      # designator implementation.
      #
      # @see DSL::Actor::Designators
      #
      def designators(&block)
        new_designators = target_eval do
          @_designators = Designators.eval(self, &block).result.freeze
        end

        Actor.register_designators(new_designators)
      end

      ##
      # Defines the boolean logic that determines whether an {Actor} is an
      # admin. Usually you'll have an +admin?+ method on your model, that you
      # can call from here. Or, feel free to just return +false+ to disable
      # this functionality.
      #
      # Example:
      #
      #   actor User do
      #     admin do |user|
      #       user.admin?
      #     end
      #   end
      #
      # @param block [Proc]
      # @return [void]
      #
      def admin(&block)
        target_eval do
          @admin_logic = block
        end
      end

      class << self
        ##
        # Looks up the given designator implementation by its +name+.
        #
        # @param name [Symbol] the designator name.
        #
        # @raise [Eaco::Malformed] if the designator is not found.
        #
        # @return [Class]
        #
        def find_designator(name)
          all_designators.fetch(name.intern)

        rescue KeyError
          raise Malformed, "Designator not found: #{name.inspect}"
        end

        ##
        # Saves the given designators in the global designators registry.
        #
        # @param new_designators [Hash]
        #
        # @return [Hash] the designators registry.
        #
        def register_designators(new_designators)
          all_designators.update(new_designators)
        end

        private
          ##
          # @return [Hash] a registry of all the defined designators.
          #
          def all_designators
            @_all_designators ||= {}
          end
      end
    end

  end
end
