# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'eaco/version'

Gem::Specification.new do |spec|
  spec.name          = "eaco-abac"
  spec.version       = Eaco::VERSION
  spec.authors       = ["Aestimo K.", "Marcello Barnaba"]
  spec.email         = ["zeros.only@proton.me"]
  spec.summary       = %q{Attribute-Based Access Control (ABAC) authorization framework for Ruby}
  spec.description   = %q{Eaco is an ABAC authorization framework: authorization decisions live in the database as per-record ACLs (designator => role), with efficient extraction of the collection of resources accessible by an actor. Maintained continuation of the eaco gem, modernized for Rails 7.2-8.1 and Ruby 3.2-4.0.}
  spec.homepage      = "https://github.com/iamaestimo/eaco"
  spec.license       = "MIT"

  spec.required_ruby_version = ">= 3.2"

  spec.metadata = {
    "homepage_uri"      => spec.homepage,
    "source_code_uri"   => spec.homepage,
    "changelog_uri"     => "#{spec.homepage}/blob/main/CHANGELOG.md",
    "rubygems_mfa_required" => "true"
  }

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
  spec.add_development_dependency "cucumber", "~> 11.0"
  # No longer a default gem as of Ruby 3.5/4.0; required by Cucumber.
  spec.add_development_dependency "ostruct"
  spec.add_development_dependency "guard-cucumber"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "guard-shell"
  spec.add_development_dependency "multi_json"
  spec.add_development_dependency "rails"
  spec.add_development_dependency "pg"
end
