module Eaco
  module Adapters
    module ActiveRecord
      class Compatibility

        ##
        # Aliases `sanitize` as `connection.quote` for ActiveRecord >= 5.1.
        #
        module Sanitized

          ##
          # Just returns +ActiveRecord::Base.connection.quote+.
          #
          def sanitize(d)
            self.connection.quote(d)
          end
        end

      end
    end
  end
end
