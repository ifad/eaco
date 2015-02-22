# Bundler
require 'bundler/setup'
require 'bundler/gem_tasks'

# YARD
require 'yard'
YARD::Rake::YardocTask.new

# RSpec
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

# Appraisal
require 'appraisal/task'
Appraisal::Task.new

# Cucumber
require 'cucumber'
require 'cucumber/rake/task'
Cucumber::Rake::Task.new

if !ENV["APPRAISAL_INITIALIZED"] && !ENV["TRAVIS"]
  desc "Runs the appraisals and generates documentation"
  task default: [ :appraisal, :yard ]
else
  desc "Runs specs"
  task default: [ :spec, :cucumber ]
end
