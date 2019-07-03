// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:cage/cage.dart' as Public;
import 'package:cage/src/_private.dart';
import 'package:flutter/widgets.dart' show Key;
import 'package:flutter_test/flutter_test.dart';

void main() {
  Injector injector;

  setUp(() {
    injector = emptyInjector.createChild(linkToParent: false);
  });

  test('Creating an instance without module shall throw', () {
    expect(
        () => CagedModule.fromModuleType(null, injector), throwsAssertionError);
  });

  test('Creating an instance without injector shall throw', () {
    expect(
        () => CagedModule.fromModuleType(Module(const ModuleKey('test')), null),
        throwsAssertionError);
  });

  group('Root property', () {
    test('The root property shall return itself', () {
      final CagedModule cagedModule =
          CagedModule.fromModuleType(Module(const ModuleKey('test')), injector);

      expect(cagedModule, cagedModule.root);
    });

    test('The root property shall return the parent', () {
      final CagedModule cagedModule = CagedModule.fromModuleType(
          Module(const ModuleKey('parent'),
              imports: [Module(const ModuleKey('child'))]),
          injector);

      cagedModule.bootstrap();

      expect(cagedModule.children[0].root, cagedModule);
    });
  });

  group('bootstrap()', () {
    group('services', () {
      test('It should register the correct core services in the injector', () {
        final CagedModule cagedModule = CagedModule.fromModuleType(
            Module(const ModuleKey('test')), injector);

        cagedModule.bootstrap();

        expect(injector.getDependency(ServiceResolver), isNotNull);
        expect(injector.getDependency(WidgetResolver), isNotNull);
      });

      test('Bootstrapping with children shall add the children to the list',
          () {
        final childModule = Module(const ModuleKey('child'));
        final parentModule =
            Module(const ModuleKey('parent'), imports: [childModule]);

        final CagedModule cagedModule =
            CagedModule.fromModuleType(parentModule, injector);

        cagedModule.bootstrap();

        expect(cagedModule.children.length, 1);
      });

      test('It should add the services correctly', () {
        final Module myModule = Module(const ModuleKey('my'), services: [
          ServiceProvider.fromValue('t', provideAs: 't'),
          {
            'value': 'u',
            'provideAs': 'u',
            'dependencies': ['test'],
            'location': Public.ServiceProviderLocation.Root,
            'instantiationType': ServiceProviderInstantiationType.OnInject
          },
          {
            'factory': (final Public.Injector injector) => 'v',
            'provideAs': 'v',
            'dependencies': [],
            'location': Public.ServiceProviderLocation.Root,
            'instantiationType': ServiceProviderInstantiationType.OnInject
          }
        ]);

        final CagedModule cagedModule =
            CagedModule.fromModuleType(myModule, injector);

        cagedModule.bootstrap();

        expect(cagedModule.services.length, 3);
        expect(cagedModule.services[0], isInstanceOf<ServiceProvider>());
        expect(cagedModule.services[1], isInstanceOf<ServiceProvider>());
        expect(cagedModule.services[2], isInstanceOf<ServiceProvider>());

        expect(cagedModule.services[0].injectionToken,
            generateRuntimeInjectionToken('t'));
        expect(cagedModule.services[1].injectionToken,
            generateRuntimeInjectionToken('u'));
        expect(cagedModule.services[2].injectionToken,
            generateRuntimeInjectionToken('v'));
      });

      test('It should throw, when an invalid provider is declared', () {
        final Module myModule =
            Module(const ModuleKey('my'), services: ['test']);

        final CagedModule cagedModule =
            CagedModule.fromModuleType(myModule, injector);

        expect(() => cagedModule.bootstrap(), throwsException);
      });

      test('It should throw, when an invalid map provider is declared', () {
        final Module myModule = Module(const ModuleKey('my'), services: [
          {'test': true}
        ]);

        final CagedModule cagedModule =
            CagedModule.fromModuleType(myModule, injector);

        expect(() => cagedModule.bootstrap(), throwsException);
      });

      test('It should throw, when invalid dependencies are provided', () {
        final Module myModule = Module(const ModuleKey('my'), services: [
          {
            'provideAs': 'test',
            'factory': (final Public.Injector injector) => 'test',
            'dependencies': 'test'
          }
        ]);

        final CagedModule cagedModule =
            CagedModule.fromModuleType(myModule, injector);

        expect(() => cagedModule.bootstrap(), throwsAssertionError);
      });

      test('It should throw, when an invalid location is provided', () {
        final Module myModule = Module(const ModuleKey('my'), services: [
          {
            'provideAs': 'test',
            'factory': (final Public.Injector injector) => 'test',
            'location': 'test'
          }
        ]);

        final CagedModule cagedModule =
            CagedModule.fromModuleType(myModule, injector);

        expect(() => cagedModule.bootstrap(), throwsAssertionError);
      });

      test('It should throw, when an invalid instantiationType is provided',
          () {
        final Module myModule = Module(const ModuleKey('my'), services: [
          {
            'provideAs': 'test',
            'factory': (final Public.Injector injector) => 'test',
            'instantiationType': 'test'
          }
        ]);

        final CagedModule cagedModule =
            CagedModule.fromModuleType(myModule, injector);

        expect(() => cagedModule.bootstrap(), throwsAssertionError);
      });
    });

    group('widgets', () {
      test('It should add the widgets correctly', () {
        final WidgetContainerFactory wcf1 = WidgetContainerFactory(
            createPresenter: (final Public.Injector injector) => null,
            createView: () => null,
            widgetKey: Key('wcf'));

        final WidgetContainerFactory wcf2 = WidgetContainerFactory(
            createPresenter: (final Public.Injector injector) => null,
            createView: () => null,
            widgetKey: Key('wcf2'));

        final Module myModule = Module(const ModuleKey('my'), widgets: [
          WidgetProvider(wcf1),
          {
            'widget': wcf2,
            'location': Public.WidgetProviderLocation.Local,
            'dependencies': []
          }
        ]);

        final CagedModule cagedModule =
            CagedModule.fromModuleType(myModule, injector);

        cagedModule.bootstrap();

        expect(cagedModule.widgets.length, 2);
        expect(cagedModule.widgets[0], isInstanceOf<WidgetProvider>());
        expect(cagedModule.widgets[1], isInstanceOf<WidgetProvider>());
      });

      test('It should throw, when an invalid provider is declared', () {
        final Module myModule =
            Module(const ModuleKey('my'), widgets: ['string']);

        final CagedModule cagedModule =
            CagedModule.fromModuleType(myModule, injector);

        expect(() => cagedModule.bootstrap(), throwsException);
      });

      test('It should throw, when an invalid object provider is declared', () {
        final Module myModule = Module(const ModuleKey('my'), widgets: [
          {'test': 'abc'}
        ]);

        final CagedModule cagedModule =
            CagedModule.fromModuleType(myModule, injector);

        expect(() => cagedModule.bootstrap(), throwsAssertionError);
      });

      test('It should throw, when an invalid location is provided', () {
        final WidgetContainerFactory wcf = WidgetContainerFactory(
            createPresenter: (final Public.Injector injector) => null,
            createView: () => null,
            widgetKey: Key('wcf'));

        final Module myModule = Module(const ModuleKey('my'), widgets: [
          {'widget': wcf, 'location': 'here'}
        ]);

        final CagedModule cagedModule =
            CagedModule.fromModuleType(myModule, injector);

        expect(() => cagedModule.bootstrap(), throwsAssertionError);
      });

      test('It should throw, when invalid dependencies are provided', () {
        final WidgetContainerFactory wcf = WidgetContainerFactory(
            createPresenter: (final Public.Injector injector) => null,
            createView: () => null,
            widgetKey: Key('wcf'));

        final Module myModule = Module(const ModuleKey('my'), widgets: [
          {'widget': wcf, 'dependencies': 'deps'}
        ]);

        final CagedModule cagedModule =
            CagedModule.fromModuleType(myModule, injector);

        expect(() => cagedModule.bootstrap(), throwsAssertionError);
      });
    });
  });
}
