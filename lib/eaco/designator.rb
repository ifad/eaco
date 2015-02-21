module Eaco

  ##
  # A Designator characterizes an Actor.
  #
  # Example: an User Actor is uniquely identified by its numerical +id+, as
  # such we can define an +user+ designator that designs User 42 as +user:42+.
  #
  # The same User also could belong to the group +frobber+, uniquely
  # identified by its name. We can then define a +group+ designator that would
  # design the same User as +group:frobber+.
  #
  # In ACLs designators are given roles, and the intersection between the
  # designators of an Actor and the ones defined in the ACL gives the role of
  # the Actor for the Resource that the ACL secures.
  #
  # Designators for actors are defined through the DSL, see {DSL::Actor}
  #
  # @see ACL
  # @see Actor
  #
  class Designator < String
    class << self

      ##
      # Instantiate a designator of the given +type+ with the given +value+.
      #
      # Example:
      #
      #   >> Designator.make('user', 42)
      #   => #<Designator(User) value:42>
      #
      # @param type [String] the designator type (e.g. +user+)
      # @param value [String] the designator value. It will be stringified using +.to_s+.
      #
      # @return [Designator]
      #
      def make(type, value)
        Eaco::DSL::Actor.find_designator(type).new(value)
      end

      ##
      # Parses a Designator string representation and instantiates a new
      # Designator instance from it.
      #
      #   >> Designator.parse('user:42')
      #   => #<Designator(User) value:42>
      #
      # @param string [String] the designator string representation.
      #
      # @return [Designator]
      #
      def parse(string)
        make(*string.split(':', 2))
      end

      ##
      # Resolves one or more designators into the target actors.
      #
      # @param designators [Array] designator string representations.
      #
      # @return [Array] resolved actors, application-dependant.
      #
      def resolve(designators)
        Array.new(designators||[]).inject([]) {|ret, d| ret.concat parse(d).resolve}
      end

      ##
      # Sets up the designator implementation with the given options.
      # Currently:
      #
      # * +:from+ - defines the method to call on the Actor to obtain the unique
      #             IDs for this Designator class.
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
      # This method is called from the DSL.
      #
      # @see DSL::Actor::Designators
      # @see DSL::Actor::Designators#define_designator
      #
      def configure!(options)
        @method = options.fetch(:from)
        self

      rescue KeyError
        raise Malformed, "The designator option :from is required"
      end

      ##
      # Harvests valid designators for the given Actor.
      #
      # It calls the +@method+ defined through the +:from+ option passed when
      # configuring the designators (see {Designator.configure!}).
      #
      # @param actor [Actor]
      #
      # @return [Array] an array of Designator objects the Actor owns.
      #
      # @see Actor
      #
      def harvest(actor)
        Array.new(actor.send(@method)||[]).map {|value| new(value) }
      end

      ##
      # Sets this Designator label to the given value.
      #
      # Example:
      #
      #   class User::Designators::Group < Eaco::Designator
      #     label "Active Directory Group"
      #   end
      #
      # @param value [String] the designator label
      #
      # @return [String] the configured label
      #
      def label(value = nil)
        @label = value if value
        @label ||= designator_name
      end

      ##
      # Returns this class' demodulized name
      #
      def designator_name
        self.name.split('::').last
      end

      ##
      # Returns the designator type.
      #
      # The type symbol is derived from the class name, on the other way
      # around, the {DSL} looks up designator implementation classes from the
      # designator type symbol.
      #
      # Example:
      #
      #   >> User::Designators::Group.id
      #   => :group
      #
      # @return [Symbol]
      #
      # @see DSL::Actor::Designators#implementation_for
      #
      def id
        @_id ||= self.designator_name.underscore.intern
      end
      alias type id

      ##
      # Searches designator definitions using the given query.
      #
      # To be implemented by derived classes. E.g. for a "User" designator
      # this would return your own User instances that you may want to display
      # in a typeahead menu, for your Enterprise authorization management
      # UI... :-)
      #
      # @raise [NotImplementedError]
      #
      def search(query)
        raise NotImplementedError
      end
    end

    ##
    # Initializes the designator with the given value. The string
    # representation is then calculated by concatenating the type and the
    # given value.
    #
    # An optional instance can be attached, if you use to pass around
    # designators in your app.
    #
    # @param value [String] the unique ID valid in this designator namespace
    # @param instance [Actor] optional Actor instance
    #
    def initialize(value, instance = nil)
      @value, @instance = value, instance
      super([ self.class.id, value ].join(':'))
    end

    # This designator unique ID in the namespace of the designator type.
    attr_reader :value

    # The instance given to {Designator#initialize}
    attr_reader :instance

    ##
    # Should return an extended description for this designator. You can then
    # use this to display it in your application.
    #
    # E.g. for an "User" designator this would be the user name, for a "Group"
    # designator this would be the group name.
    #
    # @param style [Symbol] the description style. {#as_json} uses +:full+,
    #        but you are free to define whatever styles you do see fit.
    #
    # @return [String] the description
    #
    def describe(style = nil)
      nil
    end

    ##
    # Translates this designator to concrete Actor instances in your
    # application. To be implemented by derived classes.
    #
    # @raise [NotImplementedError]
    #
    def resolve
      raise NotImplementedError
    end

    ##
    # Converts this designator to an Hash for +.to_json+ to work.
    #
    # @param options [Ignored]
    #
    # @return [Hash]
    #
    def as_json(options = nil)
      { :value => to_s, :label => describe(:full) }
    end

    ##
    # Pretty prints the designator in your console.
    #
    # @return [String]
    #
    def inspect
      %[#<Designator(#{self.class.designator_name}) value:#{value.inspect}>]
    end

    ##
    # @return [String] the designator's class label.
    #
    # @see Designator.label
    #
    def label
      self.class.label
    end

    ##
    # @return [Symbol] the designator's class type.
    #
    # @see Designator.type
    #
    def type
      self.class.type
    end
  end

end
