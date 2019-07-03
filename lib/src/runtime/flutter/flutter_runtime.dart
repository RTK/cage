// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:cage/debug.dart';
import 'package:cage/src/_private.dart';
import 'package:flutter/widgets.dart';

typedef void InitializerCallback(Widget widget);

/// Cage runtime integration for "flutter" runtime.
class FlutterRuntime {
  FlutterRuntime._internal();

  /// Bootstraps a Module.
  ///
  /// The module must provide a rootWidget, which will instantiated by calling
  /// flutter's [runApp] method.
  static void bootstrapModule(final Module module) {
    _logger.config('Bootstrap module');

    if (module.rootWidget == null) {
      runApp(FlutterRuntime._generateErrorWidget());

      throw Exception('Root module must have a bootstrap widget');
    }

    final Injector rootInjector = emptyInjector;

    _logger.info('Bootstraping module with rootInjector (emptyInjector)');

    final CagedModule cagedModule =
        CagedModule.fromModuleType(module, rootInjector, null, null);

    final Cage cage = Cage.fromCagedModule(cagedModule);

    cagedModule.bootstrap();

    _logger.info('Bootstrapping the widget factory declared as bootstrap');
    final WidgetContainer widgetContainer = cage.bootstrapWidgetFactory();

    _logger.info('Running the flutter runtime initializer');
    FlutterRuntime.initializer(widgetContainer.widget);
  }

  @visibleForTesting
  static InitializerCallback initializer = runApp;

  static Logger _logger = createLogger('runtime.flutter');

  static Widget _generateErrorWidget() => Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(color: Color.fromARGB(255, 128, 0, 0)),
          child: Center(
              child: Text('No Root widget defined',
                  style: TextStyle(
                      fontSize: 32,
                      color: Color.fromARGB(255, 255, 255, 255))))));
}
