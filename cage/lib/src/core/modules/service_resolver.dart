// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:cage/debug.dart';

import 'caged_module.dart';

import '../di/_private.dart';
import '../di/public_injector.dart' as Public;

/// The [ServiceResolver] is used to resolve services for given [_cagedModule].
class ServiceResolver {
  final CagedModule _cagedModule;

  final Map<InjectionToken, ServiceProvider> _servicesMap = Map();

  Logger _logger;

  ServiceResolver(this._cagedModule) {
    _logger = createLogger(
        'core.modules.resolvers.service_resolver(${_cagedModule.id})');
  }

  /// Bootstraps the services for given [cagedModule].
  ///
  /// Fills the [_servicesMap] to have quick access to the [ServiceResolver]'s
  /// services.
  ///
  /// Instantiates each [ServiceProvider] where the instantiationType resolves
  /// to [ServiceProviderInstantiationType.OnBoot] and each dependency, if
  /// possible.
  void bootstrap() {
    _logger.info('Bootstrap');

    if (_cagedModule.services != null && _cagedModule.services.isNotEmpty) {
      _logger.info('Acknowledging the service providers');

      final List<ServiceProvider> services = _cagedModule.services;

      for (final ServiceProvider serviceProvider in services) {
        _logger.info('Acknowledged <${serviceProvider.injectionToken}>');

        _servicesMap[serviceProvider.injectionToken] = serviceProvider;
      }

      final List<InjectionToken> bootServices = services
          .where((final ServiceProvider serviceProvider) =>
              serviceProvider.instantiationType ==
              ServiceProviderInstantiationType.OnBoot)
          .map((ServiceProvider serviceProvider) =>
              serviceProvider.injectionToken)
          .toList(growable: false);

      if (bootServices.isNotEmpty) {
        requireServices(bootServices);
      }
    } else {
      _logger.info('No services defined.');
    }
  }

  /// Instantiate a [List] of given dependencies by providing the
  /// [InjectionToken].
  void requireServices(final List<InjectionToken> serviceList) {
    _logger.info('Requiring services $serviceList');

    if (serviceList != null && serviceList.isNotEmpty) {
      for (final InjectionToken serviceToken in serviceList) {
        final _ServiceProviderResolver resolver =
            _getServiceProviderResolver(serviceToken);

        assert(resolver != null);

        _resolveService(resolver, [resolver.serviceProvider.injectionToken]);
      }
    }
  }

  @override
  String toString() {
    return 'ServiceResolver<$_cagedModule>';
  }

  /// Tries to resolve a [ServiceProvider] for given [injectionToken].
  ///
  /// Tries to resolve by iterating over each parent. If no [ServiceResolver]
  /// can resolve, null is returned.
  ///
  /// If the [ServiceProvider] can be resolved, a [_ServiceProviderResolver]
  /// instance is returned, containing the [ServiceProvider] and the
  /// [CagedModule]'s [Injector] instance.
  _ServiceProviderResolver _getServiceProviderResolver(
      final InjectionToken injectionToken) {
    CagedModule module = _cagedModule;

    do {
      final ServiceResolver moduleServiceResolver =
          module.injector.getDependency(ServiceResolver);

      _logger.severe(moduleServiceResolver);
      _logger.severe(moduleServiceResolver._servicesMap);

      if (moduleServiceResolver._servicesMap.containsKey(injectionToken)) {
        return _ServiceProviderResolver(
            moduleServiceResolver._servicesMap[injectionToken],
            _cagedModule.injector);
      }

      if (identical(module, module.parent)) {
        break;
      }

      module = module.parent;
    } while (module != null);

    return null;
  }

  /// Resolves a service from given [_ServiceProviderResolver].
  ///
  /// If the [ServiceProvider] provides dependencies, firstly those will be
  /// tried to be resolved. If at least one dependency fails to be resolved,
  /// an [Exception] is thrown.
  ///
  /// If the [ServiceProvider]'s location is set to
  /// [ServiceProviderLocation.Parent], the instance will be registered at the
  /// parent [Injector].
  ///
  /// If the [ServiceProvider]'s location is set to
  /// [ServiceProviderLocation.Root], the instance will be registered at the
  /// very root [Injector].
  void _resolveService(final _ServiceProviderResolver serviceProviderResolver,
      final List<InjectionToken> resolveChain) {
    final serviceProvider = serviceProviderResolver.serviceProvider;
    final List<InjectionToken> dependencies = serviceProvider.dependencies;

    _logger.info('Resolving service ${serviceProvider.injectionToken}');

    if (dependencies != null && dependencies.isNotEmpty) {
      final List<InjectionToken> missingProviders = [];

      _logger.severe('Service has dependencies: $dependencies');

      for (final InjectionToken dependencyToken in dependencies) {
        if (resolveChain.isNotEmpty && resolveChain.contains(dependencyToken)) {
          final InjectionToken serviceToken =
              serviceProviderResolver.serviceProvider.injectionToken;

          _logger.warning(
              'Circular dependency detected. Resolve chain: $resolveChain');

          throw Exception(
              'Circular dependency detected! Cannot instantiate "$serviceToken" since it depends on "$dependencyToken", which depends directly or indirectly on "$serviceToken".');
        }

        _logger.severe('No circular dependencies detected');

        _ServiceProviderResolver dependencyProvider =
            _getServiceProviderResolver(dependencyToken);

        if (dependencyProvider == null) {
          missingProviders.add(dependencyToken);
        } else {
          _resolveService(
              dependencyProvider,
              List.of(resolveChain)
                ..add(dependencyProvider.serviceProvider.injectionToken));
        }
      }

      if (missingProviders.isNotEmpty) {
        final String errorMessage =
            'Cannot instantiate service ${serviceProvider.injectionToken}. Missing dependencies: $missingProviders';

        _logger.warning(errorMessage);

        throw Exception(errorMessage);
      }
    } else {
      _logger.info(
          'Service ${serviceProvider.injectionToken} has no dependencies, resolving directly');
    }

    Injector targetInjector;

    switch (serviceProvider.location) {
      case ServiceProviderLocation.Parent:
        targetInjector = _cagedModule.parent.injector;
        break;

      case ServiceProviderLocation.Root:
        targetInjector = _cagedModule.root.injector;
        break;

      case ServiceProviderLocation.Local:
        targetInjector = serviceProviderResolver.injector;
        break;
    }

    final Public.Injector publicInjector =
        Public.createPublicInjector(serviceProviderResolver.injector);

    targetInjector.registerDependency(Injectable(serviceProvider.injectionToken,
        instantiateServiceFromProvider(serviceProvider, publicInjector)));
  }
}

/// The [_ServiceProviderResolver] is used to connect a [ServiceProvider] to the
/// correct target [Injector].
class _ServiceProviderResolver {
  final Injector injector;

  final ServiceProvider serviceProvider;

  const _ServiceProviderResolver(this.serviceProvider, this.injector);
}
