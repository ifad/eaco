require 'bundler/setup'
require 'byebug'
require 'eaco/cucumber'

# Connect to Active Record
Eaco::Cucumber::ActiveRecord.connect!

# Create a whole new world
World do
  Eaco::Cucumber::World.new
end
