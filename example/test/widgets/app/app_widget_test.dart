// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:cage/cage.dart';
import 'package:cage/runtime.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../lib/src/services/text_service.dart';
import '../../../lib/src/widgets/app/app_widget.dart';

void main() {
  TestCage testCage;

  setUp(() {
    final Module testModule = Module(const ModuleKey('test'), services: [
      ServiceProvider.fromFactory(
          TextService, (final Injector injector) => TextServiceStub)
    ], widgets: [
      WidgetProvider(appWidget, dependencies: [TextService])
    ]);

    testCage = FlutterTestRuntime.bootstrapModule(testModule);
  });

  group('widget app', () {
    testWidgets('It should create', (final WidgetTester widgetTester) async {
      await widgetTester
          .pumpWidget(testCage.bootstrapWidgetByKey(Key('app_widget')));

      expect(findsOneWidget, true);
    });
  });
}

class TextServiceStub extends TextService {
  String generateRandomString() => 'test';
}
