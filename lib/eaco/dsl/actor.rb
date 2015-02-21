module Eaco
  module DSL

    class Actor < Base
      autoload :Designators, 'eaco/dsl/actor/designators'

      # Initializes an Actor entity.
      #
      def initialize(*)
        super

        target_eval do
          include Eaco::Actor

          # The designators implementations defined for this Actor as an Hash
          # keyed by designator type symbol and with the concrete Designator
          # implementations as values.
          #
          def designators
            @_designators
          end

          # The logic that evaluates whether an Actor instance is an admin.
          #
          def admin_logic
            @_admin_logic
          end
        end
      end

      # Defines the designators that apply to this Actor.
      #
      # Example:
      #
      #  actor User do
      #    designators do
      #      authenticated from: :class
      #      user          from: :id
      #      group         from: :group_ids
      #    end
      # end
      #
      # Designator names are collected using `method_missing`, and are
      # named after the method name. Implementations are looked up in
      # a +Designators+ module in the Actor's class.
      #
      # Each designator implementation is expected to be named after the
      # designator's name, camelized, and inherit from Eaco::Designator.
      #
      # TODO all designators share the same namespace. This is due to the
      # fact that designator string representations aren't scoped by the
      # Actor model they belong to. As such when instantiating a designator
      # from +Eaco::Designator.make+ the registry is consulted to find the
      # designator implementation.
      #
      # See also +Eaco::DSL::Actor::Designators+.
      #
      def designators(&block)
        new_designators = target_eval do
          @_designators = Designators.eval(self, &block).freeze
        end

        Actor.register_designators(new_designators)
      end

      # Defines the boolean logic that determines whether an user is an
      # admin. Usually you'll have an `admin?` method on your model,
      # that you can call from here. Or, feel free to just return false
      # to disable this functionality.
      #
      # Example:
      #
      #   actor User do
      #     admin do |user|
      #       user.admin?
      #     end
      #   end
      #
      def admin(&block)
        target_eval do
          @admin_logic = block
        end
      end

      class << self
        # Looks up the given designator implementation by its +name+.
        #
        # Raises +Eaco::Malformed+ if the designator is not found.
        #
        def find_designator(name)
          all_designators.fetch(name.intern)

        rescue KeyError
          raise Malformed, "Designator not found: #{name.inspect}"
        end

        def register_designators(new_designators)
          all_designators.update(new_designators)
        end

        private
          # A registry of all the defined designators.
          #
          def all_designators
            @_all_designators ||= {}
          end
      end
    end

  end
end
