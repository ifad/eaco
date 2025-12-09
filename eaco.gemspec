# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'eaco/version'

Gem::Specification.new do |spec|
  spec.name          = "eaco"
  spec.version       = Eaco::VERSION
  spec.authors       = ["Marcello Barnaba"]
  spec.email         = ["vjt@openssl.it"]
  spec.summary       = %q{Authorization framework}
  spec.homepage      = "https://github.com/ifad/eaco"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "yard"
  spec.add_development_dependency "appraisal"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "cucumber"
  spec.add_development_dependency "guard-cucumber"
  spec.add_development_dependency "yard-cucumber"
  spec.add_development_dependency "coveralls"
  spec.add_development_dependency "guard-shell"
  spec.add_development_dependency "multi_json"
  spec.add_development_dependency "rails"
  spec.add_development_dependency "pg"
end
