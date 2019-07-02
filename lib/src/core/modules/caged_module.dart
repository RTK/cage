// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:cage/debug.dart';
import 'package:flutter/widgets.dart' show Key;
import 'package:meta/meta.dart';

import 'module.dart';
import 'module_key.dart';
import 'module_type.dart';
import 'service_resolver.dart';
import 'widget_resolver.dart';

import '../di/_private.dart';
import '../widgets/_private.dart';

class CagedModule {
  @visibleForTesting
  final List<CagedModule> children = [];

  final ModuleKey id;

  final List<ModuleType> imports;

  final Injector injector;

  final CagedModule parent;

  final Key rootWidget;

  final List<ServiceProvider> services = [];

  final List<WidgetProvider> widgets = [];

  final Module _module;

  final CagedModule _root;

  bool _coreServicesRegistered = false;

  get root {
    if (_root != null) {
      return _root;
    }

    return this;
  }

  Logger logger;

  CagedModule.fromModuleType(final ModuleType moduleType, this.injector,
      [this.parent, this._root])
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
    bootstrapServices();
    bootstrapWidgets();

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

  @visibleForTesting
  void bootstrapServices() {
    if (!_coreServicesRegistered) {
      _registerCoreServices();
    }

    if (_module.services != null && _module.services.isNotEmpty) {
      for (final Object provider in _module.services) {
        if (provider is ServiceProvider) {
          services.add(provider);
        } else if (provider is Map<String, dynamic>) {
          if (provider['factory'] != null) {
            services.add(ServiceProvider.fromFactory(
                provider['provideAs'], provider['factory'],
                dependencies: provider['dependencies'],
                location: provider['location'],
                instantiationType: provider['instantiationType']));
          } else if (provider['value'] != null) {
            services.add(ServiceProvider.fromValue(provider['value'],
                location: provider['location'],
                provideAs: provider['provideAs']));
          }
        } else {
          throw Exception('Invalid ServiceProvider.');
        }
      }
    }

    final ServiceResolver serviceResolver =
        injector.getDependency(ServiceResolver);

    serviceResolver.bootstrap();
  }

  @visibleForTesting
  void bootstrapWidgets() {
    if (!_coreServicesRegistered) {
      _registerCoreServices();
    }

    if (_module.widgets != null && _module.widgets.isNotEmpty) {
      for (final Object provider in _module.widgets) {
        if (provider is WidgetProvider) {
          widgets.add(provider);
        } else if (provider is Map<String, dynamic>) {
          widgets.add(WidgetProvider(provider['widget'],
              location: provider['location'],
              dependencies: provider['dependencies']));
        } else if (provider is WidgetContainerFactory) {
          widgets.add(WidgetProvider(provider));
        } else {
          throw Exception('Invalid WidgetProvider.');
        }
      }
    }

    final WidgetResolver widgetResolver =
        injector.getDependency(WidgetResolver);

    widgetResolver.bootstrap();
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
