module Eaco

  # An Actor is an entity whose access to Resources is discretionary,
  # depending on the Role this actor has in the ACL.
  #
  module Actor

    # Returns the designators granted to this user.
    #
    # See +Eaco::Designator+ for details.
    #
    def designators
      @_designators ||= Set.new.tap do |ret|
        self.class.designators.each do |_, designator|
          ret.merge designator.eval(self)
        end
      end
    end

    # Returns true if this actor fulfills the admin logic, or nil if no admin
    # logic is defined.
    #
    # This logic is called by +Resource+ Adapters' `accessible_by`, that
    # returns the full collection, and by the +Resource+ `allows?` method,
    # that bypassess access checks always returning true.
    #
    def is_admin?
      return unless self.class.admin_logic

      instance_exec(self, &self.class.admin_logic)
    end

    # Returns true if the target allows this target to perform the given action.
    #
    def can?(action, target)
      target.allows?(action, self)
    end
  end

end
