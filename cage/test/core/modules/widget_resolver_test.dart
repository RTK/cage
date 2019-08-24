// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:cage/cage.dart' as Public;
import 'package:cage/src/_private.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Injector injector;
  WidgetContainerFactory wcf;

  setUp(() {
    injector = emptyInjector.createChild(linkToParent: false);

    wcf = WidgetContainerFactory(
        createPresenter: (final Public.Injector injector) => P(),
        createView: () => V(),
        widgetKey: Key('wcf'));
  });

  group('class WidgetResolver', () {
    test('It should create an instance', () {
      final Module module = Module(const ModuleKey('Test'));

      final CagedModule cagedModule =
          CagedModule.fromModuleType(module, injector);

      expect(WidgetResolver(cagedModule), isNotNull);
    });

    test('It should throw an AssertionError, when the CagedModule is null', () {
      expect(() => WidgetResolver(null), throwsAssertionError);
    });

    group('bootstrap()', () {
      test(
          'It should add the widgetContainerFactoryProvider to the root WidgetResolver, when the location is root',
          () {
        final Module module = Module(const ModuleKey('child'), widgets: [
          WidgetProvider(
              WidgetContainerFactory(
                  createPresenter: (final Public.Injector injector) => P(),
                  createView: () => V(),
                  widgetKey: Key('wcf')),
              location: WidgetProviderLocation.Root)
        ]);

        final rootModule = Module(const ModuleKey('root'), imports: [module]);

        final CagedModule cagedModule =
            CagedModule.fromModuleType(rootModule, injector);

        cagedModule.bootstrap();

        final WidgetResolver resolver = injector.getDependency(WidgetResolver);

        resolver.bootstrap();

        expect(resolver.bootstrapWidgetByToken(Key('wcf')), isNotNull);
      });
    });

    group('bootstrapWidgetByToken()', () {
      test('It should be possible to bootstrap a declared widget', () {
        final CagedModule cagedModule = CagedModule.fromModuleType(
            Module(const ModuleKey('Test'), widgets: [wcf]), injector);

        cagedModule.bootstrap();

        final WidgetResolver resolver = injector.getDependency(WidgetResolver);

        expect(resolver.bootstrapWidgetByToken(wcf.widgetKey), isNotNull);
      });

      test('It should use the cache to retrieve the same widget again', () {
        final CagedModule cagedModule = CagedModule.fromModuleType(
            Module(const ModuleKey('Test'), widgets: [wcf]), injector);

        cagedModule.bootstrap();

        final WidgetResolver resolver = injector.getDependency(WidgetResolver);

        expect(resolver.bootstrapWidgetByToken(wcf.widgetKey), isNotNull);
        expect(resolver.bootstrapWidgetByToken(wcf.widgetKey), isNotNull);
      });

      test(
          'It should throw an AssertionError, when a non declared widget is bootstrapped',
          () {
        const Key widgetKey = Key('widget');

        final Module module = Module(const ModuleKey('Test'));

        final CagedModule cagedModule =
            CagedModule.fromModuleType(module, injector);

        final WidgetResolver resolver = WidgetResolver(cagedModule);
        resolver.bootstrap();

        expect(() => resolver.bootstrapWidgetByToken(widgetKey),
            throwsAssertionError);
      });

      test(
          'It should throw an AssertionError, when a declared widget with unresolved dependencies is bootstrapped',
          () {
        const Key widgetKey = Key('widget');

        final Module module = Module(const ModuleKey('Test'), widgets: [
          WidgetProvider(wcf, dependencies: ['A'])
        ]);

        final CagedModule cagedModule =
            CagedModule.fromModuleType(module, injector);

        final WidgetResolver resolver = WidgetResolver(cagedModule);
        resolver.bootstrap();

        expect(() => resolver.bootstrapWidgetByToken(widgetKey),
            throwsAssertionError);
      });

      group('Module inheritance', () {
        test('It should bootstrap widgets which are locationed in root', () {
          final Module childModule = Module(const ModuleKey('child'));

          final Module rootModule = Module(const ModuleKey('root'),
              imports: [childModule], widgets: [wcf]);

          final Injector childInjector = injector.createChild();

          final CagedModule rootCagedModule =
              CagedModule.fromModuleType(rootModule, injector);
          rootCagedModule.bootstrap();

          final CagedModule childCagedModule = CagedModule.fromModuleType(
              childModule, childInjector, rootCagedModule, rootCagedModule);
          childCagedModule.bootstrap();

          final WidgetResolver childResolver =
              childCagedModule.injector.getDependency(WidgetResolver);

          expect(
              childResolver.bootstrapWidgetByToken(wcf.widgetKey), isNotNull);
        });
      });

      test(
          'It should throw an AssertionError, when the widget dependencies cannot be resolved',
          () {
        final Module myModule = Module(const ModuleKey('my'), widgets: [
          WidgetProvider(wcf, dependencies: ['alf'])
        ]);

        final CagedModule cagedModule =
            CagedModule.fromModuleType(myModule, injector);

        cagedModule.bootstrap();

        final WidgetResolver resolver = injector.getDependency(WidgetResolver);

        expect(() => resolver.bootstrapWidgetByToken(Key('wcf')),
            throwsAssertionError);
      });
    });
  });
}

class P extends Presenter {}

class V extends View<P> {
  @override
  Widget createView() => Container();
}
