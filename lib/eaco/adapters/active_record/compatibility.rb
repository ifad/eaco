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

        autoload :Scoped, 'eaco/adapters/active_record/compatibility/scoped.rb'

        ##
        # Memoizes the given +model+ for later {#check!} calls.
        #
        # @param model [ActiveRecord::Base] the model to check
        #
        def initialize(model)
          @model = model
        end

        ##
        # Checks whether the target model is compatible.
        # Looks up the {#support_module} and includes it.
        #
        # @see #support_module
        #
        # @return [void]
        #
        def check!
          layer = support_module
          target.instance_eval { include layer }
        end

        private

        ##
        # @return [ActiveRecord::Base] associated with the model
        #
        def target
          @model.base_class.superclass
        end

        ##
        # @return [String] the +ActiveRecord+ major and minor version numbers
        #
        # Example: "42" for 4.2
        #
        def active_record_version
          ver = target.parent.const_get(:VERSION)
          [ver.const_get(:MAJOR), ver.const_get(:MINOR)].join
        end

        ##
        # Tries to look up the support module for the {#active_record_version}
        # in the {Compatibility} namespace.
        #
        # @return [Module] the support module
        #
        # @raise [Eaco::Error] if not found.
        #
        # @see check!
        #
        def support_module
          unless self.class.const_defined?(support_module_name)
            raise Eaco::Error, <<-EOF
              Unsupported Active Record version: #{active_record_version}
            EOF
          end

          self.class.const_get support_module_name
        end

        ##
        # @return [String] "V" with {.active_record_version} appended.
        #
        # Example: "V32" for Rails 3.2.
        #
        def support_module_name
          ['V', active_record_version].join
        end

      end

    end
  end
end
