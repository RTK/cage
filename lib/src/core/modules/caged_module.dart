// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:cage/debug.dart';
import 'package:flutter/widgets.dart' show Key;
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'module.dart';
import 'module_key.dart';
import 'module_type.dart';
import 'service_resolver.dart';
import 'widget_resolver.dart';

import '../di/_private.dart';
import '../widgets/_private.dart';

class CagedModule {
  static const String _ServiceProviderOptionDependencies = 'dependencies';

  static const String _ServiceProviderOptionFactory = 'factory';

  static const String _ServiceProviderOptionInstantiationType =
      'instantiationType';

  static const String _ServiceProviderOptionLocation = 'location';

  static const String _ServiceProviderOptionProvideAs = 'provideAs';

  static const String _ServiceProviderOptionValue = 'value';

  static const String _WidgetProviderOptionDependencies = 'dependencies';

  static const String _WidgetProviderOptionLocation = 'location';

  static const String _WidgetProviderOptionWidget = 'widget';

  @visibleForTesting
  final List<CagedModule> children = [];

  final ModuleKey id;

  final List<ModuleType> imports;

  final Injector injector;

  CagedModule get parent => _parent != null ? _parent : this;

  CagedModule get root => _root != null ? _root : this;

  final Key rootWidget;

  final List<ServiceProvider> services = [];

  final List<WidgetProvider> widgets = [];

  final Module _module;

  final CagedModule _parent;

  final CagedModule _root;

  bool _coreServicesRegistered = false;

  Logger logger;

  CagedModule.fromModuleType(final ModuleType moduleType, this.injector,
      [this._parent, this._root])
      : assert(moduleType != null),
        assert(moduleType.module != null),
        assert(moduleType.module is Module),
        assert(injector != null),
        _module = moduleType.module,
        id = moduleType.module.id,
        imports = moduleType.module.imports,
        rootWidget = moduleType.module.rootWidget != null
            ? moduleType.module.rootWidget.widgetKey
            : null {
    logger = createLogger('core.modules.caged_module($id)');
  }

  void bootstrap() {
    if (!_coreServicesRegistered) {
      _registerCoreServices();
    }

    _bootstrapImports();
    _bootstrapServices();
    _bootstrapWidgets();

    final ServiceResolver serviceResolver =
        injector.getDependency(ServiceResolver);

    serviceResolver.bootstrap();

    final WidgetResolver widgetResolver =
        injector.getDependency(WidgetResolver);

    widgetResolver.bootstrap();
  }

  void _bootstrapImports() {
    if (imports != null && imports.isNotEmpty) {
      for (final ModuleType subModuleType in imports) {
        logger.info('Bootstrap child module with root $root');

        final CagedModule childModule = CagedModule.fromModuleType(
            subModuleType,
            injector.createChild(name: subModuleType.id.toString()),
            this,
            root);

        children.add(childModule);

        childModule.bootstrap();
      }
    } else {
      logger.info('No imports defined');
    }
  }

  _bootstrapServices() {
    if (_module.services != null && _module.services.isNotEmpty) {
      for (final Object provider in _module.services) {
        ServiceProvider serviceProvider;

        if (provider is ServiceProvider) {
          logger.fine('Added service provider');

          serviceProvider = provider;
        } else if (provider is Map<String, dynamic>) {
          logger.fine('Trying to add service provider from map');

          assert(!provider.containsKey(_ServiceProviderOptionLocation) ||
              provider[_ServiceProviderOptionLocation]
                  is ServiceProviderLocation);

          if (provider.containsKey(_ServiceProviderOptionFactory)) {
            logger.finer('Found factory provider syntax');
            logger.finest(provider);

            assert(!provider.containsKey(_ServiceProviderOptionProvideAs) ||
                provider[_ServiceProviderOptionProvideAs] != null);

            assert(provider[_ServiceProviderOptionFactory] != null);

            assert(!provider.containsKey(_ServiceProviderOptionDependencies) ||
                provider[_ServiceProviderOptionDependencies] is List);

            assert(!provider
                    .containsKey(_ServiceProviderOptionInstantiationType) ||
                provider[_ServiceProviderOptionInstantiationType]
                    is ServiceProviderInstantiationType);

            serviceProvider = ServiceProvider.fromFactory(
              provider[_ServiceProviderOptionProvideAs],
              provider[_ServiceProviderOptionFactory],
              dependencies:
                  provider.containsKey(_ServiceProviderOptionDependencies)
                      ? provider[_ServiceProviderOptionDependencies]
                      : const [],
              location: provider.containsKey(_ServiceProviderOptionLocation)
                  ? provider[_ServiceProviderOptionLocation]
                  : ServiceProviderLocation.Root,
              instantiationType:
                  provider.containsKey(_ServiceProviderOptionInstantiationType)
                      ? provider[_ServiceProviderOptionInstantiationType]
                      : ServiceProviderInstantiationType.OnInject,
            );
          } else if (provider.containsKey(_ServiceProviderOptionValue)) {
            logger.finer('Found value provider syntax');
            logger.finest(provider);

            serviceProvider = ServiceProvider.fromValue(
                provider[_ServiceProviderOptionValue],
                location: provider.containsKey(_ServiceProviderOptionLocation)
                    ? provider[_ServiceProviderOptionLocation]
                    : ServiceProviderLocation.Root,
                provideAs: provider.containsKey(_ServiceProviderOptionProvideAs)
                    ? provider[_ServiceProviderOptionProvideAs]
                    : null);
          } else {
            logger.severe('Object cannot be converted to a service provider');

            throw Exception('Invalid ServiceProvider map syntax.');
          }
        } else {
          throw Exception('Invalid ServiceProvider.');
        }

        switch (serviceProvider.location) {
          case ServiceProviderLocation.Local:
            logger.fine('Add service provider locally');

            services.add(serviceProvider);
            break;

          case ServiceProviderLocation.Parent:
            logger.fine('Add service provider in parent module');

            parent.services.add(serviceProvider);
            break;

          case ServiceProviderLocation.Root:
            logger.fine('Add service provider in root module');

            root.services.add(serviceProvider);
            break;
        }
      }
    }
  }

  _bootstrapWidgets() {
    if (_module.widgets != null && _module.widgets.isNotEmpty) {
      for (final Object provider in _module.widgets) {
        WidgetProvider widgetProvider;

        if (provider is WidgetProvider) {
          logger.fine('Added widget provider');

          widgetProvider = provider;
        } else if (provider is Map<String, dynamic>) {
          logger.fine('Trying to add widget provider from map');

          assert(!provider.containsKey(_WidgetProviderOptionWidget) ||
              provider[_WidgetProviderOptionWidget] is WidgetContainerFactory);

          assert(!provider.containsKey(_WidgetProviderOptionLocation) ||
              provider[_WidgetProviderOptionLocation]
                  is WidgetProviderLocation);

          assert(!provider.containsKey(_WidgetProviderOptionDependencies) ||
              provider[_WidgetProviderOptionDependencies] is List);

          widgetProvider = WidgetProvider(provider[_WidgetProviderOptionWidget],
              location: provider.containsKey(_WidgetProviderOptionLocation)
                  ? provider[_WidgetProviderOptionLocation]
                  : WidgetProviderLocation.Local,
              dependencies:
                  provider.containsKey(_WidgetProviderOptionDependencies)
                      ? provider[_WidgetProviderOptionDependencies]
                      : const []);
        } else if (provider is WidgetContainerFactory) {
          logger.fine('Adding widget provider from factory');

          widgetProvider = WidgetProvider(provider);
        } else {
          logger.severe('Object cannot be converted to a widget provider');

          throw Exception('Invalid WidgetProvider.');
        }

        switch (widgetProvider.location) {
          case WidgetProviderLocation.Local:
            logger.fine('Add widget provider locally');

            widgets.add(widgetProvider);
            break;

          case WidgetProviderLocation.Root:
            logger.fine('Add widget provider in root module');

            root.widgets.add(widgetProvider);
            break;
        }
      }

      logger.info('Added ${widgets.length} widgets');
    }
  }

  void _registerCoreServices() {
    logger.info('Register core services');

    injector.registerDependency(Injectable(
        generateRuntimeInjectionToken(ServiceResolver), ServiceResolver(this),
        denyOverwrite: true));

    injector.registerDependency(Injectable(
        generateRuntimeInjectionToken(WidgetResolver), WidgetResolver(this),
        denyOverwrite: true));

    _coreServicesRegistered = true;
  }
}
