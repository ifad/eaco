module Eaco
  module Cucumber
    module ActiveRecord

      ##
      # This is an example of a {Eaco::Resource} that can be protected by an
      # {Eaco::ACL}. For the background story, see {Eaco::Cucumber::World}.
      #
      # @see User
      # @see Eaco::Resource
      # @see Eaco::Cucumber::World
      #
      class Document < ::ActiveRecord::Base
      end

    end
  end
end
