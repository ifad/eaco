module Eaco

  ##
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
  # @see Actor
  # @see Resource
  #
  class ACL < Hash

    ##
    # Builds a new ACL object from the given Hash representation with strings
    # as keys and values.
    #
    # @param definition [Hash] the ACL hash
    #
    # @return [ACL] this ACL
    #
    def initialize(definition = {})
      (definition || {}).each do |designator, role|
        self[designator] = role.intern
      end
    end

    ##
    # Gives the given Designator access as the given +role+.
    #
    # @param role [Symbol] the role to grant
    # @param designator [Variadic] (see {#identify})
    #
    # @return [ACL] this ACL
    #
    def add(role, *designator)
      identify(*designator).each do |key|
        self[key] = role
      end

      self
    end

    ##
    # Removes access from the given Designator.
    #
    # @param designator [Variadic] (see {#identify})
    #
    # @return [ACL] this ACL
    #
    # @see Designator
    #
    def del(*designator)
      identify(*designator).each do |key|
        self.delete(key.to_s)
      end
      self
    end

    ##
    # @param name [Symbol] The role name
    #
    # @return [Set] A set of Designators having the given +role+.
    #
    # @see Designator
    # @see Resource
    #
    def find_by_role(name)
      self.inject(Set.new) do |ret, (designator, role)|
        ret.tap { ret.add Designator.parse(designator) if role == name }
      end
    end

    ##
    # @return [Set] all Designators in the ACL, regardless of their role.
    #
    def all
      self.inject(Set.new) do |ret, (designator,_)|
        ret.add Designator.parse(designator)
      end
    end

    ##
    # Gets a map of Actors in the ACL having the given +role+.
    #
    # This is a useful starting point for an Enterprise summary page of who is
    # granted to access a resource. Given that actor resolution is dynamic and
    # handled by the application's Designators implementation, you can rely on
    # your internal organigram APIs to resolve actual people out of positions,
    # groups, department of assignment, etc.
    #
    # @param name [Symbol] The role name
    #
    # @return [Hash] keyed by designator with Set of Actors as values
    #
    # @see Actor
    # @see Resource
    #
    def designators_map_for_role(name)
      find_by_role(name).inject({}) do |ret, designator|
        actors = designator.resolve

        ret.tap do
          ret[designator] ||= Set.new
          ret[designator].merge Array.new(actors)
        end
      end
    end

    ##
    # @param name [Symbol] the role name
    #
    # @return [Set] Actors having the given +role+.
    #
    # @see Actor
    # @see Resource
    #
    def actors_by_role(name)
      find_by_role(name).inject(Set.new) do |set, designator|
        set |= Array.new(designator.resolve)
      end.to_a
    end

    ##
    # Pretty prints this ACL in your console.
    #
    def inspect
      "#<#{self.class.name}: #{super}>"
    end
    alias pretty_print_inspect inspect

    ##
    # Pretty print for +pry+.
    #
    def pretty_inspect
      "#{self.class.name}\n#{super}"
    end

    protected

    ##
    # There are three ways of specifying designators:
    #
    # * Passing an +Designator+ instance obtained from somewhere else:
    #
    #     >> designator
    #     => #<Designator(User) value:42>
    #
    #     >> resource.acl.add :reader, designator
    #     => #<Resource::ACL {"user:42"=>:reader}>
    #
    # * Passing a designator type and an unique ID valid in the designator's
    #   namespace:
    #
    #     >> resource.acl.add :reader, :user, 42
    #     => #<Resource::ACL {"user:42"=>:reader}>
    #
    # * Passing a designator type and an Actor instance, will add all
    #   designators of the given type owned by the Actor.
    #
    #     >> actor
    #     => #<User id:42 name:"Ethan Siegel">
    #
    #     >> actor.designators
    #     => #<Set:{
    #      |   #<Designator(User) value:42>,
    #      |   #<Designator(Group) value:"astrophysicists">,
    #      |   #<Designator(Group) value:"medium bloggers">
    #      | }>
    #
    #     >> resource.acl.add :editor, :group, actor
    #     => #<Resource::ACL {
    #      |   "group:astrophysicists"=>:editor,
    #      |   "group:medium bloggers"=>:editor
    #      | }
    #
    # @param designator [Designator] the designator to grant
    # @param actor_or_id [Actor] or [String] the actor
    #
    def identify(designator, actor_or_id = nil)
      if designator.is_a?(Eaco::Designator)
        [designator]

      elsif designator && actor_or_id.respond_to?(:designators)
        designator = designator.to_sym
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
