# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Changed
- Use Flutter version 1.8.0 at least via engine restriction

### Removed
- Removed some example test files

## [1.0.0] - 2019-07-07
First production release of Cage.
### Added
- Module system for creating application modules
- Dependency injection for managing dependencies to be used by widgets and other framework structures
- Widget-system to use a MVP-pattern for a better separation of concern
- State management system for strict data flow and testability
- Flutter runtime for running your Cage application with flutter
- Flutter test runtime for accessing your Cage structures, such as widgets or services in unit tests
