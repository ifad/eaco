module Eaco
  module Adapters
    module ActiveRecord
      class Compatibility

        ##
        # Aliases `scoped` as `all` for ActiveRecord >= 4.1.
        #
        # TODO maybe is against Rails' practices to revive a
        # dead API? It may be, comments accepted.
        #
        module Scoped

          ##
          # Just returns +ActiveRecord::Base.all+.
          #
          def scoped
            all
          end
        end

      end
    end
  end
end
