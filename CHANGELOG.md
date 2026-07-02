# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/) and this
project adheres to [Semantic Versioning](https://semver.org/)

## Unreleased (2.0.0.beta1)

### Changed
* **Gem renamed to `eaco-abac`** — a maintained continuation of `eaco`
  (last released 1.1.1, 2017, by ifad). The require path, `Eaco` namespace
  and DSL are unchanged: use `gem "eaco-abac", require: "eaco"`. Project
  home is now https://github.com/iamaestimo/eaco.

### Added
* Active Record compatibility modules for Rails 7.0, 7.1, 7.2, 8.0 and 8.1
  (`V70`–`V81`). The adapter previously rejected any Active Record newer than
  6.1 with "Unsupported Active Record version".

### Changed
* Replaced `coveralls` (unmaintained) with plain `SimpleCov` for coverage.
  Removed the dead Travis-only coverage-upload path from the default Rake task.
* Modernized the Railtie: use `config.enable_reloading` instead of the
  deprecated `config.cache_classes`, and drop the pre-7.x reloader fallback.
* Added `# frozen_string_literal: true` to all of `lib/`.
* Added a `Release` GitHub Actions workflow that publishes the gem on version
  tags via RubyGems Trusted Publishing (OIDC, no stored API key).
* Upgraded Cucumber from 3.2.0 to 11.x. Dropped the unmaintained
  `yard-cucumber` plugin (pinned `cucumber < 4`) and its `--plugin cucumber`
  entry in `.yardopts`. No step-definition changes were required. CI sets
  `CUCUMBER_PUBLISH_QUIET` to silence the report-publishing banner.
* **Modernization (Phase 1):** dropped support for Rails < 7.2 and Ruby < 3.2.
* Supported matrix is now Ruby 3.2–4.0 against Rails 7.2, 8.0 and 8.1.
  Full suite (RSpec + Cucumber) is green on Ruby 4.0 against all three.
* Trimmed `Appraisals` and `gemfiles/` to the supported Rails versions; added
  `gemfiles/rails_8.0.gemfile` and `gemfiles/rails_8.1.gemfile`.
* CI now tests Ruby 3.2/3.3/3.4/4.0 and triggers on the `main` branch.
* Set `required_ruby_version >= 3.2` and added gem metadata.
* Added `ostruct` as a development dependency (no longer a default gem on
  Ruby 3.5/4.0; required by Cucumber).

### Fixed
* Zeitwerk compatibility: the Railtie now parses `config/authorization.rb`
  from a `to_prepare` block instead of directly in the initializer.
  Application models cannot be autoloaded while Rails is booting on Rails 7+,
  so any rules file referencing a model made the app fail to boot with
  `NameError`. Rules are still re-parsed on each code reload in development.
  Validated end-to-end inside a freshly generated Rails 8.1 app.
* `rails db:create` no longer crashes in apps using the `:pg_jsonb` adapter:
  the ACL schema validation is skipped when the database is unreachable or
  does not exist yet, instead of propagating `ActiveRecord::NoDatabaseError`.
* Ruby 3.4+ compatibility in specs: `Eaco::ACL#inspect` / `#pretty_inspect`
  expectations now track Ruby's own `Hash` formatting (spaces around `=>`).
* Ruby 4.0 (Prism parser) compatibility: relaxed the `SyntaxError` message
  expectation in the authorization-parse-error feature.
* Removed `.config/cucumber.yml`: Cucumber 3.x cannot parse profiles via the
  removed `ERB.new` positional API on Ruby 3.4+.

### Fixed
* Fix YARD documentation warnings:
  - Remove curly braces from `@see` tags (causes rendering issues)
  - Use fully-qualified constant names for `ACL#find_by_role` references (`Eaco::ACL#find_by_role`)

## 1.1.1 - 2017-03-08

### Fixed
* Fix ActionDispatch::Reloader.to_prepare deprecation

## 1.1.0 - 2016-09-27

### Changed

* Add support for Rails 5.
