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
  # Pin cucumber: unpinned, the resolver picks wildly different versions per row
  # (10.x on some, the ancient 3.2.0 on Ruby 4) — 3.2.0 needs ostruct and the
  # profile ERB path breaks on Ruby 3.4. ~> 9.2 is consistent and Ruby-4 clean,
  # but cucumber 9 needs Ruby >= 3.0; the 2.7 row uses the last 8.x line.
  if RUBY_VERSION >= '3.0'
    spec.add_development_dependency "cucumber", "~> 9.2"
  else
    spec.add_development_dependency "cucumber", "~> 8.0"
  end
  spec.add_development_dependency "guard-cucumber"
  spec.add_development_dependency "yard-cucumber"
  spec.add_development_dependency "coveralls"
  spec.add_development_dependency "guard-shell"
  spec.add_development_dependency "multi_json"
  spec.add_development_dependency "rails"
  spec.add_development_dependency "pg"
  # Left the default gems on Ruby 3.4+ — declare them there (and only there, so
  # older rows don't pull a Ruby-3+ build of them).
  if RUBY_VERSION >= '3.4'
    spec.add_development_dependency "ostruct"
    spec.add_development_dependency "base64"
    spec.add_development_dependency "bigdecimal"
  end
  # i18n 1.15 uses Fiber storage (needs Ruby 3.2+); hold it back on the older
  # backward-compat rows so Rails 6.1 boots there.
  spec.add_development_dependency "i18n", "< 1.15" if RUBY_VERSION < '3.2'
end
