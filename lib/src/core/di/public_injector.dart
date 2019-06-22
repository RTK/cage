// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'injectable.dart';
import 'injector.dart' as Private;

/// Facade for public API usage.
///
/// Since retrieved [Injector] instances shall only be used to retrieve
/// dependencies and not overwrite anything, the public [Injector] is used to
/// cover that. The public [Injector] proxies a [Private.Injector].
class Injector implements Private.InjectorInterface {
  final Private.Injector _injector;

  Injector._internal(this._injector) {
    _injector.registerDependency(Injectable(Private.Injector.token, this));
  }

  T getDependency<T>(final Object token) {
    return _injector.getDependency(token);
  }
}

/// Creates a public [Injector] from given private [injector].
Injector createPublicInjector(final Private.Injector injector) =>
    Injector._internal(injector);
