# Bundler
require 'bundler/setup'
require 'bundler/gem_tasks'

# YARD
require 'yard'
YARD::Rake::YardocTask.new

# RSpec
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

task default: [ :spec, :yard ]
