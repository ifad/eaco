module Eaco

  class ACL < Hash
    def initialize(definition = {})
      definition.each do |designator, role|
        self[designator] = role.intern
      end
    end

    def inspect
      "#<#{self.class.name}: #{super}>"
    end
    alias :pretty_print_inspect :inspect

    def pretty_inspect
      "#{self.class.name}\n#{super}"
    end

    def add(role, designator, actor = nil)
      identify(designator, actor).each do |key|
        self[key] = role
      end

      self
    end

    def del(designator, actor = nil)
      identify(designator, actor).each do |key|
        self.delete(key)
      end

      self
    end

    def find_by_role(name)
      self.inject(Set.new) do |ret, (designator, role)|
        ret.tap { ret.add Designator.parse(designator) if role == name }
      end
    end

    def all
      self.inject(Set.new) do |ret, (designator,_)|
        ret.add Designator.parse(designator)
      end
    end

    def actors_by_role(name)
      find_by_role(name).inject({}) do |ret, designator|
        users = designator.resolve
        designator = designator.to_label if designator.respond_to?(:to_label)

        ret.tap do
          ret[designator] ||= Set.new
          ret[designator].merge Array.wrap(users)
        end
      end
    end

    def users_by_role(name)
      find_by_role(name).inject(Set.new) do |set, designator|
        set |= Array.wrap(designator.resolve)
      end.to_a
    end

    private

    def identify(designator, actor)
      if designator.is_a?(Eaco::Designator)
        [designator]

      elsif designator && actor.respond_to?(:designators)
        actor.designators.select {|d| d.type == designator}

      elsif designator.is_a?(Symbol) && actor.is_a?(String)
        [Eaco::Designator.make(designator, actor)]

      else
        raise Error, "Cannot infer designator from #{designator.inspect} and a #{actor.inspect} actor"
      end
    end
  end

end
