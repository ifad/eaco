module Eaco
  module Adapters

    module ACL
      extend self

      def install(model)
        # Create the ACL constant
        acl_class = Class.new(Eaco::ACL)
        unless model.const_defined?(:ACL)
          model.const_set(:ACL, acl_class)
        end

        # Define unmarshalers
        orm = if model.respond_to?(:base_class)
          model.base_class.superclass # Active Record
        else
          model.superclass # Naive
        end

        installer = ['install', *orm.name.split('::')].join('_')

        if self.respond_to?(installer)
          public_send(installer, model, acl_class)

        elsif (model.instance_methods & [:acl=, :acl]).size != 2
          raise Error, "Don't know how to install the ACL into #{model} - please define an `acl' accessor on it."
        end
      end

      def install_CouchRest_Model_Base(model, acl_class)
        model.instance_eval do
          property :acl, acl_class
        end
      end

      def install_ActiveRecord_Base(model, acl_class)
        column = model.columns_hash.fetch('acl', nil)

        unless column
          raise Error, "Please define a jsonb column named `acl` on #{model}"
        end

        unless column.type == :json
          raise Error, "The `acl` column on #{model} must be json"
        end

        model.class_eval do
          define_method :acl do
            acl = read_attribute(:acl)
            acl_class.new(acl)
          end

          define_method :acl= do |acl|
            write_attribute acl.to_hash
          end
        end
      end
    end

  end
end
