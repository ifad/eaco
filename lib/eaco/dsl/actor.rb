module Eaco
  module DSL

    class Actor < Base
      autoload :Designators, 'eaco/dsl/actor/designators'

      def initialize(*)
        super

        target_eval do
          include Eaco::Actor

          # The designators implementations defined for this Actor
          #
          def designators
            @_designators
          end

          # The logic that defines whether this Actor is an admin
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
      def designators(&block)
        new_designators = target_eval do
          @_designators ||= Designators.eval(self, &block).freeze
        end

        all_designators.update(new_designators)
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

      # Looks up the given designator implementation by its +name+.
      #
      # Raises +Error+ if the designator is not found.
      #
      def find_designator(name)
        all_designators.fetch(name.intern)

      rescue KeyError
        raise Error, "Designator not found: #{name.inspect}"
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
