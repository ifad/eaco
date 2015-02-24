require 'bundler/setup'
require 'byebug'

require 'coveralls'
Coveralls.wear!

require 'eaco'
require 'eaco/cucumber'

# Create a whole new world
World do
  Eaco::Cucumber::World.new
end
