module Eaco
  module DSL

    class ACL < Base
      def initialize(*)
        super

        define_role_getters
        install_persistance
      end

      private

      # Define getter methods on the ACL for each role, syntactic sugar
      # for calling find_by_role() passing the role name.
      #
      # If a `reader` role is defined, allows doing `resource.acl.readers`
      # and returns all the designators having the `reader` role set.
      #
      def define_role_getters
        roles = self.target.roles

        acl_class.instance_eval do
          roles.each do |role|
            define_method(role.to_s.pluralize) { find_by_role(role) }
          end
        end
      end

      # Runs an ORM-specific installer. If not found, checks whether an
      # .acl getter and setter are defined.
      #
      def install_persistance
        installer = ['install', *orm.name.split('::')].join('_')

        if respond_to?(installer, true)
          send(installer, acl_class)

        elsif (target.instance_methods & [:acl=, :acl]).size != 2
          raise Error, "Don't know how to install the ACL into #{target}'s ORM (#{orm}) - please define an `acl' accessor on it."
        end
      end

      # Creates the ACL constant on the target, inheriting from Eaco::ACL.
      # Removes if it is already set, so that a reload of the authorization
      # rules refreshes also these constants.
      #
      def acl_class
        @_acl_class ||= begin
          target_eval do
            remove_const(:ACL) if const_defined?(:ACL)

            Class.new(Eaco::ACL).tap do |acl_class|
              const_set(:ACL, acl_class)
            end
          end
        end
      end

      def orm
        if target.respond_to?(:base_class)
          target.base_class.superclass # Active Record
        else
          target.superclass # Naive
        end
      end

      # Install the unmarshaler for CouchRest::Model, that uses `property`.
      #
      def install_CouchRest_Model_Base(acl_class)
        target_eval do
          property :acl, acl_class
        end
      end

      # Requires a jsonb column named `acl`.
      #
      def install_ActiveRecord_Base(acl_class)
        column = target.columns_hash.fetch('acl', nil)

        unless column
          raise Error, "Please define a jsonb column named `acl` on #{target}"
        end

        unless column.type == :json
          raise Error, "The `acl` column on #{target} must be json"
        end

        target.class_eval do
          def acl
            acl = read_attribute(:acl)
            acl_class.new(acl)
          end

          def acl=(acl)
            write_attribute acl.to_hash
          end
        end
      end
    end

  end
end
