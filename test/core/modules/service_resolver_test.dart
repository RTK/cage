// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:cage/cage.dart' as Public;
import 'package:cage/src/_private.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Injector injector;

  setUp(() {
    injector = emptyInjector.createChild(linkToParent: false);
  });

  group('class ServiceResolver', () {
    group('bootstrap()', () {
      group('services with instantiationType marked as "OnBoot"', () {
        test(
            'It should resolve depdendencies from a parent module to services in its child module ',
            () {
          Module childModule = Module(const ModuleKey('child'), services: [
            ServiceProvider.fromFactory(
                ServiceBTest,
                (final Public.Injector injector) =>
                    ServiceBTest(injector.getDependency(ServiceTest)),
                dependencies: [ServiceTest])
          ]);

          Module parentModule = Module(const ModuleKey('parent'), imports: [
            childModule
          ], services: [
            ServiceProvider.fromFactory(
                ServiceTest, (final Public.Injector injector) => ServiceTest(),
                instantiationType: ServiceProviderInstantiationType.OnBoot)
          ]);

          final CagedModule cagedModule =
              CagedModule.fromModuleType(parentModule, injector);

          cagedModule.bootstrap();

          expect(injector.getDependency(ServiceTest), isNotNull);
        });

        test('It should resolve any in root provided service', () {
          final Module childModule =
              Module(const ModuleKey('child'), services: [
            ServiceProvider.fromFactory(
                ServiceTest, (final Public.Injector injector) => ServiceTest(),
                location: ServiceProviderLocation.Root,
                instantiationType: ServiceProviderInstantiationType.OnBoot)
          ]);

          final Module parentModule =
              Module(const ModuleKey('parent'), imports: [childModule]);

          final CagedModule cagedModule =
              CagedModule.fromModuleType(parentModule, injector);

          cagedModule.bootstrap();

          expect(injector.getDependency(ServiceTest), isNotNull);
        });

        test(
            'It should not resolve a locally provided service for ancestor services',
            () {
          final Module childModule =
              Module(const ModuleKey('child'), services: [
            ServiceProvider.fromFactory(
                ServiceTest, (final Public.Injector injector) => ServiceTest(),
                location: ServiceProviderLocation.Local,
                instantiationType: ServiceProviderInstantiationType.OnBoot)
          ]);

          final Module parentModule =
              Module(const ModuleKey('parent'), imports: [childModule]);

          final CagedModule cagedModule =
              CagedModule.fromModuleType(parentModule, injector);

          cagedModule.bootstrap();

          expect(() => injector.getDependency(ServiceTest), throwsException);
        });

        test('It should be possible to register multiple services', () {
          final Module module = Module(const ModuleKey('test'), services: [
            ServiceProvider.fromValue('Test', provideAs: 'Test'),
            ServiceProvider.fromValue('TestB', provideAs: 'TestB'),
            ServiceProvider.fromValue('TestC', provideAs: 'TestC'),
            ServiceProvider.fromFactory(
                ServiceDTest,
                (final Public.Injector injector) =>
                    ServiceDTest(injector.getDependency(ServiceCTest)),
                dependencies: [ServiceCTest],
                instantiationType: ServiceProviderInstantiationType.OnBoot),
            ServiceProvider.fromFactory(ServiceCTest,
                (final Public.Injector injector) => ServiceCTest(),
                instantiationType: ServiceProviderInstantiationType.OnBoot)
          ]);

          final CagedModule cagedModule =
              CagedModule.fromModuleType(module, injector);

          cagedModule.bootstrap();

          expect(cagedModule.injector.getDependency('Test'), isNotNull);
          expect(cagedModule.injector.getDependency('TestB'), isNotNull);
          expect(cagedModule.injector.getDependency('TestC'), isNotNull);
          expect(cagedModule.injector.getDependency(ServiceDTest), isNotNull);
          expect(cagedModule.injector.getDependency(ServiceCTest), isNotNull);
        });
      });

      group('services with instantiationType marked as "OnInject"', () {
        test('It should not register services directly', () {
          final ServiceProvider serviceProvider = ServiceProvider.fromFactory(
              ServiceTest, (final Public.Injector injector) => ServiceTest());

          expect(serviceProvider.instantiationType,
              ServiceProviderInstantiationType.OnInject);

          final Module module =
              Module(const ModuleKey('test'), services: [serviceProvider]);

          final CagedModule cagedModule =
              CagedModule.fromModuleType(module, injector);

          cagedModule.bootstrap();

          expect(() => cagedModule.injector.getDependency(ServiceTest),
              throwsException);
        });

        test('It should create the service, when required', () {
          final Module module = Module(const ModuleKey('test'), services: [
            ServiceProvider.fromFactory(
                ServiceBTest, (final Public.Injector injector) => ServiceBTest,
                dependencies: [ServiceTest],
                instantiationType: ServiceProviderInstantiationType.OnBoot),
            ServiceProvider.fromFactory(
                ServiceTest, (final Public.Injector injector) => ServiceTest,
                instantiationType: ServiceProviderInstantiationType.OnInject)
          ]);

          final CagedModule cagedModule =
              CagedModule.fromModuleType(module, injector);

          cagedModule.bootstrap();

          expect(cagedModule.injector.getDependency(ServiceBTest), isNotNull);
        });
      });
    });

    group('requireServices()', () {
      test('It should throw an Exception, when a provider cannot be resolved',
          () {
        expect(
            () => ServiceResolver(CagedModule.fromModuleType(
                    Module(const ModuleKey('test')), injector))
                .requireServices([const InjectionToken('test')]),
            throwsException);
      });

      group('resolving', () {
        test(
            'It should throw, when a provider can be resolved, but not its dependencies',
            () {
          final Module myModule = Module(const ModuleKey('my'), services: [
            ServiceProvider.fromFactory(
                ServiceBTest,
                (final Public.Injector injector) =>
                    ServiceBTest(injector.getDependency(ServiceTest)),
                dependencies: [ServiceTest])
          ]);

          final CagedModule cagedModule =
              CagedModule.fromModuleType(myModule, injector);

          cagedModule.bootstrap();

          final ServiceResolver serviceResolver =
              injector.getDependency(ServiceResolver);

          expect(
              () => serviceResolver.requireServices(
                  [generateRuntimeInjectionToken(ServiceBTest)]),
              throwsException);
        });

        test('It should recognize circular dependencies', () {
          final Module myModule = Module(const ModuleKey('my'), services: [
            ServiceProvider.fromFactory(
                ServiceTest, (final Public.Injector injector) => ServiceTest(),
                dependencies: [ServiceBTest]),
            ServiceProvider.fromFactory(
                ServiceBTest,
                (final Public.Injector injector) =>
                    ServiceBTest(injector.getDependency(ServiceTest)),
                dependencies: [ServiceCTest]),
            ServiceProvider.fromFactory(ServiceCTest,
                (final Public.Injector injector) => ServiceCTest(),
                dependencies: [ServiceDTest]),
            ServiceProvider.fromFactory(
                ServiceDTest,
                (final Public.Injector injector) =>
                    ServiceDTest(injector.getDependency(ServiceCTest)),
                dependencies: [ServiceTest, ServiceCTest])
          ]);

          final CagedModule cagedModule =
              CagedModule.fromModuleType(myModule, injector);

          cagedModule.bootstrap();

          final ServiceResolver serviceResolver = ServiceResolver(cagedModule);

          expect(
              () => serviceResolver.requireServices(
                  [generateRuntimeInjectionToken(ServiceTest)]),
              throwsException);
        });

        test('It should use the parent injector, when the location is parent',
            () {
          final Module childModule =
              Module(const ModuleKey('child'), services: [
            ServiceProvider.fromFactory(
                ServiceTest, (final Public.Injector injector) => ServiceTest(),
                location: Public.ServiceProviderLocation.Parent)
          ]);

          final Module parentModule =
              Module(const ModuleKey('parent'), imports: [childModule]);

          final CagedModule cagedModule =
              CagedModule.fromModuleType(parentModule, injector);

          cagedModule.bootstrap();

          final ServiceResolver serviceResolver =
              injector.getDependency(ServiceResolver);

          serviceResolver
              .requireServices([generateRuntimeInjectionToken(ServiceTest)]);

          expect(injector.getDependency(ServiceTest), isNotNull);
        });

        test(
            'It should use its injector when the location is parent, but there is no parent',
            () {
          final Module module = Module(const ModuleKey('module'), services: [
            ServiceProvider.fromFactory(
                ServiceTest, (final Public.Injector injector) => ServiceTest(),
                location: Public.ServiceProviderLocation.Parent)
          ]);

          final CagedModule cagedModule =
              CagedModule.fromModuleType(module, injector);

          cagedModule.bootstrap();

          final ServiceResolver serviceResolver =
              injector.getDependency(ServiceResolver);

          serviceResolver
              .requireServices([generateRuntimeInjectionToken(ServiceTest)]);

          expect(injector.getDependency(ServiceTest), isNotNull);
        });
      });
    });
  });
}

class ServiceTest {}

class ServiceBTest {
  ServiceTest dependency;

  ServiceBTest(this.dependency);
}

class ServiceCTest {}

class ServiceDTest {
  final ServiceCTest service;

  ServiceDTest(this.service);
}
