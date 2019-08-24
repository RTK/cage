# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
###Added
- Build integration
    - Cage is using `build_runner` to transform framework source code
- Added dependency `build_runner`
    
### Changed
- Bump `Flutter` version to at least `1.9.5`
- Bump `Dart` version to at least `2.5.0` (Flutter dependency)
- Bump dependency `meta` version to at least `1.1.7`

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
