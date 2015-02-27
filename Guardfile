# Eaco's Guardfile

# Watch lib/ and spec/
directories %w(lib spec features)

# Clear the screen before every task
clearing :on

guard :rspec, version: 3, cmd: 'bundle exec rspec' do
  # When single specs change, run them.
  watch(%r{^spec/.+_spec\.rb$})

  # When spec_helper changes rerun all the specs.
  watch('spec/spec_helper.rb') { "spec" }

  # When a source changes run its unit spec.
  watch(%r{^lib/(.+)\.rb$}) {|m| "spec/#{m[1]}_spec.rb" }
end

guard :cucumber do
  # When single features change, run them.
  watch(%r{^features/.+\.feature$})

  # When support code changes, rerun all features.
  watch(%r{^features/support/.+$}) { 'features' }

  # When a step definition for a feature changes, rerun the corresponding feature.
  watch(%r{^features/step_definitions/(.+)_steps\.rb$}) { |m| Dir[File.join("**/#{m[1]}.feature")][0] || 'features' }
end

guard :shell do
  # Rerun scenarios when source code changes
  watch(%r{^lib/.+\.rb$}) { system 'cucumber' }
end
