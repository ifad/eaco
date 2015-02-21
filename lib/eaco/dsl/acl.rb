require 'eaco/dsl/base'

module Eaco
  module DSL

    ##
    # Block-less DSL to set up the {ACL} machinery onto an authorized {Resource}.
    #
    # * Defines an {ACL} subclass in the Resource namespace
    # * Defines syntactic sugar on the ACL to easily retrieve {Actor}s with a
    #   specific Role
    # * Installs {ACL} objects persistance for the supported ORMs
    # * Installs the authorized collection extraction strategy +.accessible_by+
    #
    class ACL < Base

      ##
      # Performs ACL setup on the target Resource class.
      #
      # @see #define_acl_subclass
      # @see #define_role_getters
      # @see #install_persistance
      #
      def initialize(*)
        super

        define_acl_subclass
        define_role_getters
        install_persistance
      end

      private

      ##
      # Creates the ACL constant on the target, inheriting from {Eaco::ACL}.
      # Removes if it is already set, so that a reload of the authorization
      # rules refreshes also these constants.
      #
      # The ACL subclass can be retrieved using the +.acl+ singleton method
      # on the {Resource} class.
      #
      # @return [void]
      #
      def define_acl_subclass
        target_eval do
          remove_const(:ACL) if const_defined?(:ACL)

          Class.new(Eaco::ACL).tap do |acl_class|
            define_singleton_method(:acl) { acl_class }
            const_set(:ACL, acl_class)
          end
        end
      end

      ##
      # Define getter methods on the ACL for each role, syntactic sugar
      # for calling {ACL#find_by_role}.
      #
      # Example:
      #
      # If a +reader+ role is defined, allows doing +resource.acl.readers+
      # and returns all the designators having the +reader+ role set.
      #
      # @return [void]
      #
      def define_role_getters
        roles = self.target.roles

        target.acl.instance_eval do
          roles.each do |role|
            define_method(role.to_s.pluralize) { find_by_role(role) }
          end
        end
      end

      ##
      # Sets up the persistance layer for ACLs (+#acl+ and +#acl=+) and the
      # authorized collection extraction strategy (+.accessible_by+).
      #
      # All these APIs can be implemented directly in your models, as
      # long as the +acl+ accessor accepts and returns the model's ACL
      # subclass (see {.define_acl_subclass}); and the +.accessible_by+
      # returns an +Enumerable+ collection.
      #
      # See each adapter for the details of the extraction strategies
      # they provide.
      #
      # @return [void]
      #
      def install_persistance
        adapter = {
          'ActiveRecord::Base'     => Eaco::Adapters::ActiveRecord,
          'CouchRest::Model::Base' => Eaco::Adapters::CouchrestModel,
        }.fetch(orm.name, nil)

        if adapter
          target.instance_eval { include adapter }

        elsif target.respond_to?(:acl) && target.respond_to?(:acl=)
          raise Malformed, <<-EOF
            Don't know how to persist ACLs using <#{target}>'s ORM
            (identified as <#{orm}>). Please define an `acl' instance
            accessor on <#{target}> that accepts and returns a <#{target.acl}>.
          EOF
        end

        if adapter && (strategy = adapter.strategies[ options.fetch(:using, nil) ])
          target.extend strategy
        end

        unless target.respond_to?(:accessible_by)
          strategies = adapter.strategies.keys

          raise Malformed, <<-EOF
            Don't know how to look up authorized records on <#{target}>'s
            ORM (identified as <#{orm}>). To authorize <#{target}>

            #{ unless strategies.blank?
              "either use one of the available strategies: #{strategies.join(', ')} or"
            end }

            please define your own #{target}.accessible_by method.
            You may at one point want to move this in a new strategy,
            and send a pull request :-).
          EOF
        end
      end

      ##
      # Tries to naively identify which ORM the target model is using.
      #
      # TODO support more stuff
      #
      # @return [Class] the ORM base class.
      #
      def orm
        if target.respond_to?(:base_class)
          target.base_class.superclass # Active Record
        else
          target.superclass # Naive
        end
      end
    end

  end
end
