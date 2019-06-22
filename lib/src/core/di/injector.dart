// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:meta/meta.dart';

import 'injectable.dart';
import 'injection_token.dart';

abstract class InjectorInterface {
  T getDependency<T>(final Object injectionToken);
}

/// The [Injector] class handles dependencies.
///
/// Dependencies (named injectables) can be registered with an [InjectionToken]
/// and will be retrieved using this [InjectionToken].
///
/// An [Injector] may have a parent [Injector] and will resolve dependencies
/// using the ancestor's dependencies as well.
///
/// Dependencies can be overwritten using an equal [InjectionToken], since
/// resolving starts from bottom-up.
@protected
class Injector implements InjectorInterface {
  /// Represents the [InjectionToken] which will be used to register itself
  /// to be accessible via DI.
  static InjectionToken token = generateRuntimeInjectionToken(Injector);

  /// Contains all registered dependencies. Takes an [InjectionToken] as key
  /// and any kind of [Object] as value.
  final Map<InjectionToken, Injectable> _dependencies = Map();

  /// Reference to the parent [Injector]. May be null (see [_emptyInjector])
  ///
  /// Will be used to resolve dependencies registered in any ancestor
  /// [Injector].
  final Injector _parent;

  final String _name;

  /// Creates a new [Injector] instance.
  ///
  /// Registers itself with the [InjectionToken] [Injector] as dependency so
  /// it can be accessed at runtime
  Injector._internal(this._parent, [this._name]) {
    registerDependency(Injectable(token, this));
  }

  /// Creates a child [Injector], providing this current instance as parent
  Injector createChild({final bool linkToParent = true, final String name}) =>
      Injector._internal(linkToParent ? this : null, name);

  /// Returns if the injector can resolve the dependency for given
  /// [InjectionToken].
  ///
  /// To resolve, the method traverses the complete chain of injectors
  /// upwards to try resolving the dependency.
  bool hasDependency(final InjectionToken token) {
    Injector injector = this;

    do {
      if (injector._dependencies.containsKey(token)) {
        return true;
      }

      injector = injector._parent;
    } while (injector != null);

    return false;
  }

  /// Returns if the [Injector] can satisfy a [List] of [InjectionToken].
  ///
  /// Uses the function hasDependency for each [List] item.
  bool hasDependencies(final List<InjectionToken> tokens) {
    bool hasAll = true;

    for (final InjectionToken token in tokens) {
      if (!hasDependency(token)) {
        hasAll = false;

        break;
      }
    }

    return hasAll;
  }

  /// registers a dependency for the given injection token
  ///
  /// if overwrite is not defined it will resolve to true
  /// if overwrite resolves to false and the dependency is already registered
  /// the dependency will not be registered
  void registerDependency(final Injectable injectable) {
    if (_dependencies.containsKey(injectable.injectionToken) &&
        _dependencies[injectable.injectionToken].denyOverwrite) {
      throw Exception(
          'The injectable already is registered and must not be overwritten');
    }

    _dependencies[injectable.injectionToken] = injectable;
  }

  /// Retrieves a dependency from the [Injector] chain.
  ///
  /// If a dependency is registered it will be returned. If not, the ancestor
  /// chain will be iterated as long as there is a parent. The first [Injector]
  /// to return a dependency for given [injectionToken] will provide the
  /// injectable.
  ///
  /// If no [Injector] can resolve the dependency, an [Exception] is thrown.
  T getDependency<T>(final Object injectionToken) {
    final InjectionToken token = generateRuntimeInjectionToken(injectionToken);

    Injector injector = this;

    do {
      if (injector._dependencies.containsKey(token)) {
        return injector._dependencies[token].instance;
      }

      injector = injector._parent;
    } while (injector != null);

    throw Exception('There is no dependency with token $token registered');
  }

  @override
  String toString() =>
      this._name != null ? this._name : _dependencies.toString();
}

/// Empty injector containing no dependencies but itself and providing no
/// parent (null)
Injector emptyInjector = Injector._internal(null, 'root');
