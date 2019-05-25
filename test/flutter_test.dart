import 'package:cage/core/core.dart' show CagedModule;
import 'package:cage/flutter.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart' show Container, Widget, runApp;
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'bootstrapping a module without a root widget should throw an error',
      (WidgetTester widgetTester) {
    CagedModule module = CagedModuleStub('Test');

    expect(() {
      CagedFlutter.bootstrapModule(module);
    }, throwsA(anything));
  });

  testWidgets(
      'bootstrapping a module with a root widget should call the flutter runApp method with given root widget',
      (WidgetTester widgetTester) async {
    bool isInitialized = false;

    CagedFlutter.initializer = (Widget widget) {
      isInitialized = true;
    };

    CagedModule module = CagedModuleStub('Test', bootstrap: Container());

    CagedFlutter.bootstrapModule(module);

    expect(isInitialized, true);

    runApp(module.bootstrap);

    await widgetTester.pump();
    await widgetTester.pump();

    final Finder findContainer =
        find.byWidgetPredicate((Widget widget) => widget is Container);

    expect(findContainer, findsOneWidget);

    await widgetTester.pump();
  });
}

class CagedModuleStub extends CagedModule {
  CagedModuleStub(String id, {Widget bootstrap})
      : super(id, bootstrap: bootstrap);
}
