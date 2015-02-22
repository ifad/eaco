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

  step = lambda {|msg| $stderr.puts ">>>\n>>> EACO: #{msg}\n>>>\n" }

  desc "Runs the appraisals and generates documentation"
  task :default do
    step[ 'Running all appraisals' ]
    pid = fork { Rake::Task[:appraisal].invoke }
    _, status = Process.wait2(pid)
    unless status.exitstatus == 0
      raise "*** EACO: Appraisals failed with status #{status.exitstatus}"
    end

    step[ 'Generating documentation' ]
    Rake::Task[:yard].invoke
  end

else
  desc "Runs specs"
  task default: [ :spec, :cucumber ]
end
