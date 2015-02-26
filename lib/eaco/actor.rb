module Eaco

  ##
  # An Actor is an entity whose access to Resources is discretionary,
  # depending on the Role this actor has in the ACL.
  #
  # The role of this +Actor+ is calculated from the +Designator+ that
  # the actor instance has, and the +ACL+ instance attached to the
  # +Resource+.
  #
  # @see ACL
  # @see Resource
  # @see DSL::Actor
  #
  module Actor

    # @private
    def self.included(base)
      base.extend ClassMethods
    end

    ##
    # Singleton methods added to Actor classes.
    #
    module ClassMethods
      ##
      # The designators implementations defined for this Actor as an Hash
      # keyed by designator type symbol and with the concrete Designator
      # implementations as values.
      #
      # @see DSL::Actor#initialize
      #
      def designators
      end

      ##
      # The logic that evaluates whether an Actor instance is an admin.
      #
      # @see DSL::Actor#initialize
      #
      def admin_logic
      end
    end

    ##
    # @return [Set] the designators granted to this Actor.
    #
    # @see Designator
    #
    def designators
      @_designators ||= Set.new.tap do |ret|
        self.class.designators.each do |_, designator|
          ret.merge designator.harvest(self)
        end
      end
    end

    ##
    # Checks whether this Actor fulfills the admin logic.
    #
    # This logic is called by +Resource+ Adapters' +accessible_by+, that
    # returns the full collection, and by {Resource#allows?}, that bypassess
    # access checks always returning true.
    #
    # @return [Boolean] True or False if admin logic is defined, nil if not.
    #
    def is_admin?
      return unless self.class.admin_logic

      instance_exec(self, &self.class.admin_logic)
    end

    ##
    # Checks wether the given Resource allows this Actor to perform the given action.
    #
    # @param action [Symbol] a valid action for this Resource (see {DSL::Resource})
    # @param resource [Resource] an authorized resource
    #
    # @see Resource
    #
    def can?(action, resource)
      resource.allows?(action, self)
    end

    ##
    # Opposite of {#can?}.
    #
    # @param (see #can?)
    # @return (see #can?)
    #
    def cannot?(*args)
      !can?(*args)
    end
  end

end
