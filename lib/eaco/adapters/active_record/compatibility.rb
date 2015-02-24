module Eaco
  module Adapters
    module ActiveRecord

      ##
      # Sets up JSONB support for the different AR versions
      #
      class Compatibility
        autoload :V32, 'eaco/adapters/active_record/compatibility/v32.rb'
        autoload :V40, 'eaco/adapters/active_record/compatibility/v40.rb'
        autoload :V41, 'eaco/adapters/active_record/compatibility/v41.rb'
        autoload :V42, 'eaco/adapters/active_record/compatibility/v42.rb'

        def initialize(model)
          @model = model
        end

        def check!
          layer = support_module
          base.instance_eval { include layer }
        end

        private

        def base
          @model.base_class.superclass
        end

        def active_record_version
          ver = base.parent::VERSION
          [ver.const_get(:MAJOR), ver.const_get(:MINOR)].join
        end

        def support_module
          unless self.class.const_defined?(support_module_name)
            raise Eaco::Error, <<-EOF
              Unsupported Active Record version: #{active_record_version}
            EOF
          end

          self.class.const_get support_module_name
        end

        def support_module_name
          ['V', active_record_version].join
        end

      end

    end
  end
end
