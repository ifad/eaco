module Eaco

  ##
  # Namespace that holds all cucumber-related helpers.
  #
  module Cucumber
    autoload :ActiveRecord, 'eaco/cucumber/active_record.rb'
    autoload :World,        'eaco/cucumber/world.rb'
  end

end
