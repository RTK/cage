// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:cage/src/_private.dart';
import 'package:flutter/widgets.dart';

const Symbol _defaultNotFoundValue = const Symbol('noValueGiven');

class TestCage {
  final Cage _cage;

  TestCage(this._cage);

  /// Tries to bootstrap a registered WidgetContainerFactory's widget.
  ///
  /// If [options] object is provided it will be passed to the create presenter.
  Widget bootstrapWidgetByKey(final Key widgetKey, [final Object options]) {
    final WidgetResolver widgetResolver =
        _cage.injector.getDependency(WidgetResolver);

    final WidgetContainer widgetContainer =
        widgetResolver.bootstrapWidgetByToken(widgetKey, options);

    return widgetContainer.widget;
  }

  /// Tries to return instantiated dependency for [token].
  ///
  /// Accepts a [notFoundValue], which will be returned in case the dependency
  /// is not found.
  ///
  /// If the dependency cannot be found and not [notFoundValue] is provided,
  /// an [Exception] is thrown.
  T getService<T>(final Object token,
      [final dynamic notFoundValue = _defaultNotFoundValue]) {
    try {
      return _cage.injector.getDependency(token);
    } catch (e) {
      if (notFoundValue != _defaultNotFoundValue) {
        return notFoundValue;
      }

      rethrow;
    }
  }

  /// Returns a readable string
  @override
  String toString() {
    return 'TestCage <$_cage>';
  }
}
