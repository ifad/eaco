require 'bundler/setup'
require 'byebug'
require 'eaco/cucumber'

Eaco::Cucumber::ActiveRecord.connect!
