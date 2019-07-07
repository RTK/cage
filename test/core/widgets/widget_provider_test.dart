// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:cage/src/_private.dart';
import 'package:cage/cage.dart' as Public;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  WidgetContainerFactory wcf;

  setUp(() {
    wcf = WidgetContainerFactory(
        widgetKey: Key('wcf'),
        createView: () => null,
        createPresenter: (final Public.Injector injector) => null);
  });

  group('class WidgetProvider', () {
    test('It should create', () {
      expect(
          WidgetContainerFactory(
              widgetKey: Key('wcf'),
              createView: () => null,
              createPresenter: (final Public.Injector injector) => null),
          isNotNull);
    });

    test(
        'It should throw an AssertionError when trying to create without factory',
        () {
      expect(() => WidgetProvider(null), throwsAssertionError);
    });

    test('It should generate the injectionToken from the key', () {
      final WidgetProvider wcfp = WidgetProvider(wcf);

      expect(wcfp.injectionToken,
          InjectionToken.generateFromObject(wcf.widgetKey));
    });
  });
}
