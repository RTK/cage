// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'caged_module.dart';
import 'widget_resolver.dart';

import '../widgets/widget_container.dart';

class Cage {
  final CagedModule _cagedModule;

  const Cage.fromCagedModule(this._cagedModule);

  /// Resolves the bootstrap [WidgetContainer].
  WidgetContainer bootstrapWidgetFactory() {
    assert(_cagedModule.rootWidget != null);

    final WidgetResolver widgetResolver =
        _cagedModule.injector.getDependency(WidgetResolver);

    final WidgetContainer widgetContainer =
        widgetResolver.bootstrapWidgetByToken(_cagedModule.rootWidget, null);

    return widgetContainer;
  }
}
