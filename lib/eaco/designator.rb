module Eaco

  class Designator < String
    class << self
      def make(type, value)
        Eaco::DSL::Actor.designators.fetch(type.intern).new(value)
      rescue KeyError
        raise Error, "Designator not found: #{type.inspect}"
      end

      def parse(designator)
        make(*designator.split(':', 2))
      end

      # Resolves one or more designators into the target users
      #
      def resolve(designators)
        Array.wrap(designators).inject([]) {|ret, d| ret.concat parse(d).resolve}
      end

      def configure!(options)
        @method = options.fetch(:from)
        self
      end

      def id
        @id ||= self.name.demodulize.underscore.intern
      end
      alias :type :id

      def eval(actor)
        Array.wrap(actor.send(@method)).map {|value| new(value) }
      end

      def label(value = nil)
        @label = value if value
        @label ||= name.demodulize
      end

      def search(query)
        raise NotImplementedError
      end
    end

    def initialize(value, instance = nil)
      @value, @instance = value, instance
      super([ self.class.id, value ].join(':'))
    end
    attr_reader :value, :instance

    delegate :label, :to => 'self.class'

    def describe(style = nil)
      nil
    end

    def resolve
      raise NotImplementedError
    end

    def type
      self.class.id
    end

    def inspect
      %[#<#{self.class.name} #{self.to_s.inspect}>]
    end

    def as_json(options = nil)
      { :value => to_s, :label => describe(:full) }
    end
  end

end
