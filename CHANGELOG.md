# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/) and this
project adheres to [Semantic Versioning](https://semver.org/)

## Unreleased

### Fixed
* Fix YARD documentation warnings:
  - Remove curly braces from `@see` tags (causes rendering issues)
  - Use fully-qualified constant names for `ACL#find_by_role` references (`Eaco::ACL#find_by_role`)

## 1.2.0 - 2026-06-18

### Added
* Rails 8.1 / Ruby 4.0.5 support.
* `Adapters::ActiveRecord::Compatibility::Modern` support module, used for
  every Active Record major >= 7. Previously the compatibility layer raised
  "Unsupported Active Record version" on anything past 6.1; new Rails majors
  no longer require an identical per-version `Vxx` module.
* Self-contained smoke harness (`test/smoke.rb`) plus a CI matrix sweeping
  Ruby 4.0.5/3.4/2.7 across Rails 8.1/7.2/6.1.

## 1.1.1 - 2017-03-08

### Fixed
* Fix ActionDispatch::Reloader.to_prepare deprecation

## 1.1.0 - 2016-09-27

### Changed

* Add support for Rails 5.
