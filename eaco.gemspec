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

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"

  spec.add_development_dependency "rspec"
  spec.add_development_dependency "actionpack"

  spec.add_development_dependency "yard"
  spec.add_development_dependency "yard-rspec"

  spec.add_development_dependency "byebug"

  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-rspec"
end
