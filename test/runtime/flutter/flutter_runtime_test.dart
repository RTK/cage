// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:cage/cage.dart';
import 'package:cage/runtime.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  WidgetContainerFactory wcf;

  setUp(() {
    wcf = WidgetContainerFactory(
        createPresenter: (final Injector injector) => TestPresenter(),
        createView: () => TestView(),
        widgetKey: Key('MyWidget'));
  });

  testWidgets(
      'bootstrapping a module without a root widget should throw an error',
      (WidgetTester widgetTester) {
    Module module = Module(const ModuleKey('Test'));

    expect(() => FlutterRuntime.bootstrapModule(module), throwsException);
  });

  testWidgets(
      'bootstrapping a module with a root widget should call the flutter runApp method with given root widget',
      (final WidgetTester widgetTester) async {
    bool isInitialized = false;

    FlutterRuntime.initializer = (Widget widget) {
      isInitialized = true;

      runApp(widget);
    };

    final Module module = Module(const ModuleKey('Test'),
        rootWidget: wcf, widgets: [WidgetProvider(wcf)]);

    FlutterRuntime.bootstrapModule(module);

    expect(isInitialized, true);

    await widgetTester.pump();
    await widgetTester.pump();

    final Finder findContainer =
        find.byWidgetPredicate((Widget widget) => widget is Container);

    expect(findContainer, findsOneWidget);

    await widgetTester.pump();
  });
}

class TestPresenter extends Presenter {
  TestPresenter() : super();
}

class TestView extends View<TestPresenter> {
  @override
  Widget createView() => Container();
}
