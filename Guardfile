# Eaco's Guardfile

# Watch lib/ and spec/
directories %w(lib spec)

# Clear the screen before every task
clearing :on

guard :rspec, version: 3, cmd: 'rspec' do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }
end
