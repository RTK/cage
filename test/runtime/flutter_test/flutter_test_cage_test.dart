// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:cage/cage.dart' as Public show Injector;
import 'package:cage/src/_private.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TestCage', () {
    Injector injector;

    setUp(() {
      injector = emptyInjector.createChild(linkToParent: false);
    });

    group('bootstrapWidgetByKey()', () {
      testWidgets('It should create defined widget',
          (final WidgetTester widgetTester) async {
        const Key widgetKey = Key('myWidget');

        final WidgetContainerFactory wcf = WidgetContainerFactory(
            createView: () => MyView(),
            createPresenter: (final Public.Injector injector) => MyPresenter(),
            widgetKey: widgetKey);

        final Module module = Module(const ModuleKey('test'), widgets: [wcf]);

        final CagedModule cagedModule =
            CagedModule.fromModuleType(module, injector);

        cagedModule.bootstrap();

        final Cage cage = Cage.fromCagedModule(cagedModule);

        final TestCage testCage = TestCage(cage);

        await widgetTester.pumpWidget(testCage.bootstrapWidgetByKey(widgetKey));

        await widgetTester.pump();

        final Finder findContainer =
            find.byWidgetPredicate((Widget widget) => widget is Container);

        expect(findContainer, findsOneWidget);

        await widgetTester.pump();
      });
    });

    group('get()', () {
      test('It should return the correct dependency', () {
        final Module module = Module(const ModuleKey('test'), services: [
          ServiceProvider.fromFactory(
              TestService, (final Public.Injector injector) => TestService(),
              instantiationType: ServiceProviderInstantiationType.OnBoot)
        ]);

        final CagedModule cagedModule =
            CagedModule.fromModuleType(module, injector);

        cagedModule.bootstrap();

        final Cage cage = Cage.fromCagedModule(cagedModule);

        final TestCage testCage = TestCage(cage);

        expect(testCage.getService(TestService), isNotNull);
      });

      test('It should return the notFound value for the dependency', () {
        final Module module = Module(const ModuleKey('test'));

        final CagedModule cagedModule =
            CagedModule.fromModuleType(module, injector);

        cagedModule.bootstrap();

        final Cage cage = Cage.fromCagedModule(cagedModule);

        final TestCage testCage = TestCage(cage);

        expect(testCage.getService('Test123', 'test123'), 'test123');
      });

      test(
          'It should throw an error, when the dependency cannot be found and no default value is provided',
          () {
        final Module module = Module(const ModuleKey('test'));

        final CagedModule cagedModule =
            CagedModule.fromModuleType(module, injector);

        cagedModule.bootstrap();

        final Cage cage = Cage.fromCagedModule(cagedModule);

        final TestCage testCage = TestCage(cage);

        expect(() => testCage.getService('Test123'), throwsException);
      });
    });

    group('toString()', () {
      test('It should return the correct string', () {
        final Module module = Module(const ModuleKey('test'), services: [
          ServiceProvider.fromFactory(
              TestService, (final Public.Injector injector) => TestService(),
              instantiationType: ServiceProviderInstantiationType.OnBoot)
        ]);

        final CagedModule cagedModule =
            CagedModule.fromModuleType(module, injector);

        cagedModule.bootstrap();

        final Cage cage = Cage.fromCagedModule(cagedModule);

        final TestCage testCage = TestCage(cage);

        expect(testCage.toString(),
            'TestCage <Cage <CagedModule <Module <ModuleKey key="test">>>>');
      });
    });
  });
}

class TestService {}

class MyPresenter extends Presenter {}

class MyView extends View {
  @override
  Widget createView() => Container();
}
