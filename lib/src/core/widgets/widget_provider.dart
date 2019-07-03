// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

import 'widget_container_factory.dart';

import '../di/_private.dart';

enum WidgetProviderLocation { Root, Local }

/// [WidgetProvider] is used to register a [WidgetContainerFactory] to a module.
class WidgetProvider {
  final WidgetContainerFactory factory;

  final List<InjectionToken> dependencies;

  /// Indicates the location of provide.
  final WidgetProviderLocation location;

  /// Returns the [InjectionToken] for the [WidgetContainerFactory] and its
  /// underlying WidgetContainer.
  ///
  /// Uses the [Key] required for instantiation for creation.
  InjectionToken get injectionToken =>
      generateRuntimeInjectionToken(factory.widgetKey);

  WidgetProvider(this.factory,
      {final List<Object> dependencies: const [],
      location = WidgetProviderLocation.Local})
      : assert(factory != null),
        this.dependencies = dependencies != null && dependencies.isNotEmpty
            ? dependencies.map(generateRuntimeInjectionToken).toList()
            : const [],
        this.location =
            location != null ? location : WidgetProviderLocation.Local;
}
