library cage.flutter;

import 'package:flutter/widgets.dart';

import './cage.dart';

typedef void InitializerCallback(Widget widget);

class CagedFlutter {
  /// bootstraps a CagedModule
  ///
  /// the module must provide a bootstrap widget which will instantiated from
  /// the get go.
  static void bootstrapModule(CagedModule module) {
    if (module.bootstrap == null) {
      runApp(CagedFlutter._generateErrorWidget());

      throw 'Root module must have a bootstrap widget';
    }

    ModuleRegistry().registerModule(module, true);

    CagedFlutter.initializer(module.bootstrap);
  }

  @visibleForTesting
  static InitializerCallback initializer = runApp;

  static Widget _generateErrorWidget() => Directionality(
      child: Container(
          decoration: BoxDecoration(color: Color.fromARGB(255, 255, 122, 122)),
          child: Text('No Root widget defined',
              style: TextStyle(color: Color.fromARGB(255, 255, 255, 122)))),
      textDirection: TextDirection.ltr);
}
