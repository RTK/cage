// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:cage/debug.dart';
import 'package:flutter/widgets.dart';

import 'caged_module.dart';
import 'service_resolver.dart';

import '../di/_private.dart';
import '../di/public_injector.dart' as Public;
import '../widgets/_private.dart';

/// Resolves widgets by looking for registered [WidgetContainerFactoryProvider]s
/// in the [cagedModule]
class WidgetResolver {
  final CagedModule _cagedModule;

  final Injector _injector;

  final Map<Key, _ProviderResolver> _providers = Map();

  final Map<Key, _WidgetContainerFactoryResolver> _resolutions = Map();

  Logger _logger;

  get rootResolver {
    if (!identical(_cagedModule.root, _cagedModule)) {
      return _cagedModule.root.injector.getDependency(WidgetResolver);
    }

    return this;
  }

  /// Public and default constructor to create a [WidgetResolver].
  ///
  /// Tries to find the [_rootResolver], when given [cagedModule] provides a
  /// root. If not, the instance itself works as the [_rootResolver].
  ///
  /// Additionally iterates each widget of the [cagedModule]s widget [List].
  /// If the location equals [WidgetContainerProvideLocation.Local], the
  /// resolution is added locally. If the location equals
  /// [WidgetContainerProvideLocation.Root], the resolution is added to the
  /// [_rootResolver].
  WidgetResolver(this._cagedModule)
      : assert(_cagedModule != null),
        _injector = _cagedModule.injector {
    _logger = createLogger(
        'core.modules.resolvers.widget_resolver(${_cagedModule.id})');
  }

  /// Bootstraps the [WidgetResolver].
  ///
  /// Acknowledges the widget providers. This means each provider is added to
  /// this instance or the root [WidgetResolver], so they can be instantiated
  /// later.
  void bootstrap() {
    _logger.info('Bootstrapping');

    if (_cagedModule.widgets != null && _cagedModule.widgets.isNotEmpty) {
      _logger.info('Acknowledging the widget providers');

      for (final WidgetProvider widgetContainerFactoryProvider
          in _cagedModule.widgets) {
        if (widgetContainerFactoryProvider.location ==
            WidgetProviderLocation.Local) {
          _logger.info(
              'Adding provider locally, ${widgetContainerFactoryProvider.injectionToken}');
          _addProvider(widgetContainerFactoryProvider, _injector);
        } else if (widgetContainerFactoryProvider.location ==
            WidgetProviderLocation.Root) {
          _logger.info(
              'Adding provider in root, ${widgetContainerFactoryProvider.injectionToken}');

          rootResolver._addProvider(widgetContainerFactoryProvider, _injector);
        }
      }
    } else {
      _logger.info('No widgets defined');
    }
  }

  /// Bootstraps a [WidgetContainer] by given [widgetToken] with optional
  /// [widgetOptions].
  ///
  /// If the [WidgetContainerFactory] can be resolved, the [WidgetContainer]
  /// factory method is called with a new child [Injector].
  ///
  /// If the [WidgetContainerFactory] cannot be resolved, an [Exception] is
  /// thrown.
  WidgetContainer bootstrapWidgetByToken(final Key widgetToken,
      [final Object widgetOptions]) {
    final _WidgetContainerFactoryResolver resolvedContainerFactory =
        _resolve(widgetToken);

    assert(resolvedContainerFactory != null);

    final WidgetContainerFactory factory =
        resolvedContainerFactory.widgetContainerFactory;

    final Public.Injector widgetInjector =
        Public.createPublicInjector(resolvedContainerFactory.injector);

    return createWidgetContainer(factory, widgetInjector, widgetOptions);
  }

  /// Adds a new provider to the providers.
  void _addProvider(final WidgetProvider provider, final Injector injector) {
    final _ProviderResolver resolver = _ProviderResolver(provider, injector);

    _providers[provider.factory.widgetKey] = resolver;
  }

  /// Instantiates (or re uses cached) [WidgetContainerFactory] for given
  /// [widgetToken].
  ///
  /// If the [WidgetContainerFactoryProvider] already has been resolved, the
  /// cached value from [_resolutions] is returned.
  /// Otherwise the [WidgetContainerFactory] will be instantiated, cached and
  /// returned.
  _WidgetContainerFactoryResolver _instantiate(final Key widgetToken) {
    if (_resolutions.containsKey(widgetToken)) {
      return _resolutions[widgetToken];
    }

    final _ProviderResolver providerResolver = _providers[widgetToken];
    final WidgetProvider provider = providerResolver.provider;
    final Injector injector = providerResolver.injector;

    final ServiceResolver serviceResolver =
        injector.getDependency(ServiceResolver);

    final List<InjectionToken> dependencies = provider.dependencies
        .map(generateRuntimeInjectionToken)
        .where((InjectionToken injectionToken) =>
            !injector.hasDependency(injectionToken))
        .toList(growable: false);

    if (dependencies.isNotEmpty) {
      serviceResolver.requireServices(dependencies);
    }

    _resolutions[widgetToken] =
        _WidgetContainerFactoryResolver(provider.factory, injector);

    return _resolutions[widgetToken];
  }

  /// Tries to resolve a [WidgetContainerFactory] for given [widgetToken].
  ///
  /// Firstly tries to resolve locally, looking into the [_providers] map.
  /// If not found locally, tries to resolve by looking into the
  /// [_rootResolver]s map.
  ///
  /// If no resolver can resolve, null is returned.
  _WidgetContainerFactoryResolver _resolve(final Key widgetToken) {
    _logger.info('Resolving for $widgetToken. Context: ${_cagedModule.id}');
    if (_providers.containsKey(widgetToken)) {
      _logger.info('WidgetContainer $widgetToken is resolved locally');

      return _instantiate(widgetToken);
    } else if (rootResolver._providers.containsKey(widgetToken)) {
      _logger.info('WidgetContainer $widgetToken is resolved from root');

      return rootResolver._instantiate(widgetToken);
    }

    _logger.warning('WidgetContainer $widgetToken cannot be resolved');

    return null;
  }
}

class _ProviderResolver {
  final WidgetProvider provider;

  final Injector injector;

  const _ProviderResolver(this.provider, this.injector);
}

class _WidgetContainerFactoryResolver {
  final Injector injector;

  final WidgetContainerFactory widgetContainerFactory;

  const _WidgetContainerFactoryResolver(
      this.widgetContainerFactory, this.injector);
}
