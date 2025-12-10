# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/) and this
project adheres to [Semantic Versioning](https://semver.org/)

## Unreleased

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
