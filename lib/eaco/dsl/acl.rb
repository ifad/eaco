require 'eaco/dsl/base'

module Eaco
  module DSL

    ##
    # Block-less DSL to set up the {ACL} machinery onto an authorized {Resource}.
    #
    # * Defines an {ACL} subclass in the Resource namespace
    #   ({#define_acl_subclass})
    #
    # * Defines syntactic sugar on the ACL to easily retrieve {Actor}s with a
    #   specific Role ({#define_role_getters})
    #
    # * Installs {ACL} objects persistance for the supported ORMs
    #   ({#install_persistance})
    #
    # * Installs the authorized collection extraction strategy
    #   +.accessible_by+ ({#install_strategy})
    #
    class ACL < Base

      ##
      # Performs ACL setup on the target Resource model.
      #
      # @return [nil]
      #
      def initialize(*)
        super

        define_acl_subclass
        define_role_getters
        install_persistance
        install_strategy

        nil
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
          remove_const(:ACL) if const_defined?(:ACL, false)

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
      # Sets up the persistance layer for ACLs (+#acl+ and +#acl=+).
      #
      # These APIs can be implemented directly in your Resource model, as long
      # as the +acl+ accessor accepts and returns the Resource model's ACL
      # subclass (see {.define_acl_subclass})
      #
      # See each adapter for the details of the extraction strategies
      # they provide.
      #
      # @return [void]
      #
      def install_persistance
        if adapter
          target.send(:include, adapter)
          install_authorized_collection_strategy

        elsif (target.instance_methods & [:acl, :acl=]).size != 2
          raise Malformed, <<-EOF
            Don't know how to persist ACLs using <#{target}>'s ORM
            (identified as <#{orm}>). Please define an `acl' instance
            accessor on <#{target}> that accepts and returns a <#{target.acl}>.
          EOF
        end
      end

      ##
      # Sets up the authorized collection extraction strategy
      # (+.accessible_by+).
      #
      # This API can be implemented directly in your model, as long as
      # +.accessible_by+ returns an +Enumerable+ collection.
      #
      # @return [void]
      #
      def install_strategy
        unless target.respond_to?(:accessible_by)
          strategies = adapter ? adapter.strategies.keys : []

          raise Malformed, <<-EOF
            Don't know how to look up authorized records on <#{target}>'s
            ORM (identified as <#{orm}>). To authorize <#{target}>

            #{ if strategies.size > 0
              "either use one of the available strategies: #{strategies.join(', ')} or"
            end }

            please define your own #{target}.accessible_by method.
            You may at one point want to move this in a new strategy,
            and send a pull request :-).
          EOF
        end
      end

      ##
      # Looks up the authorized collection strategy within the Adapter,
      # using the +:using+ option given to the +authorize+ Resource DSL
      #
      # @see DSL::Resource
      #
      # @return [void]
      #
      def install_authorized_collection_strategy
        if adapter && (strategy = adapter.strategies[ options.fetch(:using, nil) ])
          target.extend strategy
        end
      end

      ##
      # Tries to identify which ORM adapter to use for the +target+ class.
      #
      # @return [Class] the adapter implementation or nil if not available.
      #
      def adapter
        { 'ActiveRecord::Base'     => Eaco::Adapters::ActiveRecord,
          'CouchRest::Model::Base' => Eaco::Adapters::CouchrestModel,
        }.fetch(orm.name, nil)
      end

      ##
      # Tries to naively identify which ORM the target model is using.
      #
      # TODO support more stuff
      #
      # @return [Class] the ORM base class.
      #
      def orm
        if defined?(ActiveRecord::Base) && target.ancestors.include?(ActiveRecord::Base)
          ActiveRecord::Base
        else
          target.superclass # Naive
        end
      end
    end

  end
end
