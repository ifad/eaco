require 'bundler/setup'
require 'byebug'

require 'coveralls'
Coveralls.wear!

require 'eaco'
require 'eaco/cucumber'

##
# Create a whole new world.
# @see {World}
# @!method World
World do
  Eaco::Cucumber::World.new
end

##
# Recreate the schema before each feature, to start fresh.
# @see {ActiveRecord.define_schema!}
# @!method Before
Before do
  Eaco::Cucumber::ActiveRecord.define_schema!
end
