// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'injection_token.dart';
import 'public_injector.dart' as Public;

typedef FactoryProvider<T> = T Function(Public.Injector);

enum ServiceProviderInstantiationType { OnBoot, OnInject }

enum ServiceProviderLocation { Local, Parent, Root }

enum ServiceProviderType { Factory, Value }

class ServiceProvider<T> {
  final ServiceProviderInstantiationType instantiationType;

  final ServiceProviderLocation location;

  final ServiceProviderType type;

  final List<InjectionToken> dependencies;

  final FactoryProvider<T> _factoryProvider;

  final T _instance;

  final Object _injectionToken;

  /// Returns a runtime generated [InjectionToken] using the value of
  /// [_injectionToken].
  InjectionToken get injectionToken =>
      generateRuntimeInjectionToken(_injectionToken);

  /// Creates a service provider (injectable) from a factory
  /// the factory is represented as a factory provider callback which returns
  /// the instance.
  ///
  /// If no [InjectionToken] for the [ServiceProvider] is given, an
  /// [InjectionToken] will automatically be created from the runtime type of
  /// the injectable
  ServiceProvider.fromFactory(
      final Object provideAs, final FactoryProvider<T> factoryProvider,
      {final List<Object> dependencies = const [],
      final ServiceProviderInstantiationType instantiationType,
      final ServiceProviderLocation location})
      : assert(provideAs != null),
        assert(factoryProvider != null),
        this.instantiationType = instantiationType != null
            ? instantiationType
            : ServiceProviderInstantiationType.OnInject,
        this.location =
            location != null ? location : ServiceProviderLocation.Root,
        type = ServiceProviderType.Factory,
        _injectionToken = provideAs,
        _instance = null,
        _factoryProvider = factoryProvider,
        this.dependencies = dependencies != null && dependencies.isNotEmpty
            ? dependencies.map(generateRuntimeInjectionToken).toList()
            : const [];

  /// Creates a service provider (injectable) from a value (instance).
  ///
  /// If no [InjectionToken] for the [ServiceProvider] is given, an
  /// [InjectionToken] will automatically be created from the runtime type of
  /// the injectable
  const ServiceProvider.fromValue(this._instance,
      {final Object provideAs, final ServiceProviderLocation location})
      : assert(_instance != null),
        instantiationType = ServiceProviderInstantiationType.OnBoot,
        this.location =
            location != null ? location : ServiceProviderLocation.Root,
        type = ServiceProviderType.Value,
        _factoryProvider = null,
        _injectionToken = provideAs != null ? provideAs : _instance,
        this.dependencies = const [];
}

/// Returns the original value used for the generation of [InjectionToken] for
/// a [ServiceProvider].
Object getServiceProviderOriginalToken<S>(
        final ServiceProvider<S> serviceProvider) =>
    serviceProvider._injectionToken;

/// Creates the service's instance.
///
/// If the [type] equals [ServiceProviderType.Value], no further operation
/// will be done and the [_instance] is returned instantly.
///
/// Otherwise the the [resolvedDependencies] will be added to a new
/// [DependencyProvider] which will be used for requiring the service's
/// dependencies.
///
/// If the [type] equals [ServiceProviderType.Factory], the [_factoryProvider]
/// callback will be invoked, providing the resolved [DependencyProvider].
///
/// If the [type] equals [ServiceProviderType.Class], an Exception is thrown.
/// Currently Dart does not support creating runtime instances of Types.
///
/// If, whatever reason, the type did not match any of these cases, an
/// exception will be thrown.
T instantiateServiceFromProvider<T>(
    final ServiceProvider<T> serviceProvider, final Public.Injector injector) {
  if (serviceProvider.type == ServiceProviderType.Value) {
    return serviceProvider._instance;
  }

  return serviceProvider._factoryProvider(injector);
}
