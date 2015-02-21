module Eaco

  # A Designator characterizes an Actor.
  #
  # Example: an User Actor is uniquely identified by its numerical `id`, as
  # such we can define an "user" designator that designs User 42 as "user:42".
  #
  # The same User also could belong to the group "frobber", uniquely
  # identified by its name. We can then define a "group" designator that would
  # design the same user as "group:frobber".
  #
  # In ACLs designators are given roles, and the intersection between the
  # designators of an Actor and the ones defined in the ACL gives the role of
  # the Actor for the Resource that the ACL secures.
  #
  # Designators are defined through the DSL, see +Eaco::DSL::Actor+
  #
  class Designator < String
    class << self

      # Instantiate a designator of the given `type` with the given `value`.
      #
      # Example:
      #
      #   >> Designator.make('user', 42)
      #   => #<Designator type:user value:42>
      #
      def make(type, value)
        Eaco::DSL::Actor.find_designator(type).new(value)
      end

      # Parses a Designator string representation and instantiates a new
      # Designator instance from it.
      #
      #   >> Designator.parse('user:42')
      #   => #<Designator type:user value:42>
      #
      def parse(string)
        make(*string.split(':', 2))
      end

      # Resolves one or more designators into the target users
      #
      def resolve(designators)
        Array.wrap(designators).inject([]) {|ret, d| ret.concat parse(d).resolve}
      end

      # Sets up the designator implementation with the given
      # options. Currently:
      #
      #   :from - defines the method to call on the Actor to obtain the unique
      #           IDs for this Designator class.
      #
      # Example configuration:
      #
      #   actor User do
      #     designators do
      #       user  from: :id
      #       group from: :group_ids
      #     end
      #   end
      #
      # This method is called from the DSL (See Eaco::DSL::Actor::Designators).
      #
      def configure!(options)
        @method = options.fetch(:from)
        self

      rescue KeyError
        raise Malformed, "The designator option :from is required"
      end

      # Harvests valid designators for the given Actor.
      #
      # It calls the +@method+ defined through the :from option passed when
      # configuring the designators (see +Designator.configure!+ above).
      #
      def harvest(actor)
        Array.wrap(actor.send(@method)).map {|value| new(value) }
      end

      # Sets this Designator label to the given value.
      #
      # Example:
      #
      # class User::Designators::Group < Eaco::Designator
      #   label "Active Directory Group"
      # end
      #
      def label(value = nil)
        @label = value if value
        @label ||= name.demodulize
      end

      # Returns the designator type as a symbol.
      #
      # The type symbol is derived from the designator class name.
      #
      # On the other way around, the DSL looks up designator implementations
      # by camelizing the designator type symbol.
      #
      # See +Eaco::DSL::Actor::Designators+ for details.
      #
      # Example:
      #
      #   >> User::Designators::Group.id
      #   => :group
      #
      def id
        @_id ||= self.name.demodulize.underscore.intern
      end
      alias type id

      # Searches designator definitions using the given query.
      #
      # To be implemented by derived classes. E.g. for a "User" designator
      # this would return your own User instances that you may want to display
      # in a typeahead menu, for your Enterprise authorization management
      # UI... :-)
      #
      def search(query)
        raise NotImplementedError
      end
    end

    # Initializes the designator with the given value. The string
    # representation is then calculated by concatenating the type and the
    # given value.
    #
    # An optional instance can be attached, if you use to pass around
    # designators in your app.
    #
    def initialize(value, instance = nil)
      @value, @instance = value, instance
      super([ self.class.id, value ].join(':'))
    end

    attr_reader :value, :instance

    # Should return an extended description for this designator. You can then
    # use this to display it in your application.
    #
    # E.g. for an "User" designator this would be the user name, for a "Group"
    # designator this would be the group name.
    #
    def describe(style = nil)
      nil
    end

    # Translates this designator to concrete Actor instances in your
    # application. To be implemented by derived classes.
    #
    def resolve
      raise NotImplementedError
    end

    # Converts this designator to an Hash for the .to_json API
    #
    def as_json(options = nil)
      { :value => to_s, :label => describe(:full) }
    end

    # Pretty prints the designator in your console
    #
    def inspect
      %[#<Designator(#{self.class.name.demodulize}) value:#{value.inspect}>]
    end

    # Returns the designator's class label
    #
    def label
      self.class.label
    end

    # Returns the designator's class type
    #
    def type
      self.class.id
    end
  end

end
