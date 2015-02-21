module Eaco

  # An ACL is an Hash whose keys are Designator string representations and
  # values are the role symbols defined in the Resource permissions
  # configuration.
  #
  # Example:
  #
  #   authorize Document do
  #     roles :reader, :editor
  #   end
  #
  # See +Eaco::Resource+ and +Eaco::DSL::Resource+ for details.
  #
  class ACL < Hash

    # Interns the role symbols from the key-value string representation.
    #
    def initialize(definition = {})
      definition.each do |designator, role|
        self[designator] = role.intern
      end
    end

    # Gives the given +designator+ access as the given +role+.
    #
    # For details on arguments, please see +identify+ below.
    #
    def add(role, *designator)
      identify(*designator).each do |key|
        self[key] = role
      end

      self
    end

    # Removes access from the given designator.
    #
    # For details on arguments, please see +identify+ below.
    #
    def del(*designator)
      identify(*designator).each do |key|
        self.delete(key)
      end

      self
    end

    # Returns a +Set+ of +Designator+s having the given +role+.
    #
    def find_by_role(name)
      self.inject(Set.new) do |ret, (designator, role)|
        ret.tap { ret.add Designator.parse(designator) if role == name }
      end
    end

    # Returns a +Set+ of all +Designator+s in the ACL, regardless of their role.
    #
    def all
      self.inject(Set.new) do |ret, (designator,_)|
        ret.add Designator.parse(designator)
      end
    end

    # Returns an +Hash+ of +Actor+s in the ACL having the given role name,
    # with designators as keys.
    #
    # This is a useful starting point for an Enterprise summary page of who is
    # granted to access a resource. Given that actor resolution is dynamic and
    # handled by the application's Designators implementation, you can rely on
    # your internal organigram APIs to resolve actual people out of positions,
    # groups, department of assignment, etc.
    #
    def designators_map_for_role(name)
      find_by_role(name).inject({}) do |ret, designator|
        actors = designator.resolve

        ret.tap do
          ret[designator] ||= Set.new
          ret[designator].merge Array.wrap(actors)
        end
      end
    end

    # Returns a +Set+ of actors having the given role name.
    #
    def actors_by_role(name)
      find_by_role(name).inject(Set.new) do |set, designator|
        set |= Array.wrap(designator.resolve)
      end.to_a
    end

    def inspect
      "#<#{self.class.name}: #{super}>"
    end
    alias :pretty_print_inspect :inspect

    def pretty_inspect
      "#{self.class.name}\n#{super}"
    end

    private

    # There are three ways of specifying designators:
    #
    # * Passing an +Eaco::Designator+ instance obtained from somewhere else:
    #
    #    >> designator
    #    => #<Eaco::Designator type:user value:42>
    #    >> resource.acl.add :reader, designator
    #    => #<Resource::ACL {"user:42"=>:reader}>
    #
    # * Passing a designator type and an unique ID valid in the designator's
    #   namespace:
    #
    #   >> resource.acl.add :reader, :user, 42
    #   => #<Resource::ACL {"user:42"=>:reader}>
    #
    # * Passing a designator type and an Actor instance, will add all
    #   designators of the given type owned by the Actor.
    #
    #    >> actor
    #    => #<User id:42 name:"Ethan Siegel">
    #    >> actor.designators
    #    => #<Set:{
    #     |   #<Eaco::Designator type:user, value:42>,
    #     |   #<Eaco::Designator type:group, value:"astrophysicists">,
    #     |   #<Eaco::Designator type:group, value:"medium bloggers">
    #     | }>
    #    >> resource.acl.add :editor, :group, actor
    #    => #<Resource::ACL {
    #     |   "group:astrophysicists"=>:editor,
    #     |   "group:medium bloggers"=>:editor
    #     | }
    #
    def identify(designator, actor_or_id)
      if designator.is_a?(Eaco::Designator)
        [designator]

      elsif designator && actor_or_id.respond_to?(:designators)
        actor_or_id.designators.select {|d| d.type == designator}

      elsif designator.is_a?(Symbol)
        [Eaco::Designator.make(designator, actor_or_id)]

      else
        raise Error, <<-EOF
          Cannot infer designator
          from #{designator.inspect}
          and #{actor_or_id.inspect}
        EOF
      end
    end
  end

end
