> Put your flutter in a cage 
# Cage &middot; [![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/RTK/cage/blob/master/LICENSE)  [![Pub Package](https://img.shields.io/pub/v/cage.svg)](https://pub.dartlang.org/packages/cage) [![Build Status](https://travis-ci.com/RTK/cage.svg?branch=develop)](https://travis-ci.com/RTK/cage) [![codecov](https://codecov.io/gh/RTK/cage/branch/develop/graph/badge.svg)](https://codecov.io/gh/RTK/cage)

Cage is an opinionated framework for developing [Flutter](https://flutter.io) applications. Cage aims to provide structure and guidance in a new world of cross platform mobile app development.

Cage builds onto the concepts of dependency-injection (DI), model-view-presenter (MVP) and flux-style pattern for interactions.

> The command line interface (CLI) is hosted in this [repository](https://github.com/RTK/cage_cli)

# Overview
cage consists of three fundamental foundations:
* Modules
* Services
* Widgets

## Modules
A module represents a modular package to be used upon other modules or bootstrapping the application. A module declares services and widgets. Modules can import other modules, so that module parts can be reused and shared.

[Looking for examples?](doc/modules.md)

## Services
A service can be any object you like. A service can be a number, a string or a complex class instance. Services can be provided to the complete application or be isolated in your current module.

[Looking for examples?](doc/services.md)

## Widgets
Since Flutter is build on widgets, cage of course cannot avoid widgets. Cage wraps cages and provides separation of concern for widgets. While Flutter does not give any rules for structuring your widgets, Cage has an opinion for you.
Business logic and view logic are separated, your models shall exist separately.

[Looking for examples?](doc/widgets.md)

### Don't quite like what you see?
Flutter currently does not provide any access to metadata. Thus fancy metadata/annotations used by libraries like angular currently do not work out of the box. For further development build_tools will be evaluated and may can be used productive someday. This will hopefully decrease the usage of currently needed boiletplate code.
