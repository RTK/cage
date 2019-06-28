// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:cage/cage.dart' as Public;
import 'package:cage/src/_private.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('class ServiceProvider', () {
    group('get injectionToken', () {
      test('It should return the correct injectionToken instance', () {
        final ServiceProvider sp =
            ServiceProvider.fromValue('a', provideAs: 'Test');

        expect(sp.injectionToken, generateRuntimeInjectionToken('Test'));
      });
    });

    group('constructor fromFactory', () {
      test('It should create', () {
        expect(
            ServiceProvider.fromFactory(
                'a', (final Public.Injector injector) => 'a'),
            isNotNull);
      });

      test('It should throw an AssertionError, when provideAs is null', () {
        expect(
            () => ServiceProvider.fromFactory(
                null, (final Public.Injector injector) => 'a'),
            throwsAssertionError);
      });

      test('It should throw an AssertionError, when the factory is null', () {
        expect(
            () => ServiceProvider.fromFactory('a', null), throwsAssertionError);
      });

      test('It should set the default properties correctly', () {
        final ServiceProvider sp = ServiceProvider.fromFactory(
            'a', (final Public.Injector injector) => 'a');
        expect(sp.location, ServiceProviderLocation.Root);
        expect(sp.instantiationType, ServiceProviderInstantiationType.OnInject);
      });

      test('It should assign the properties correctly, when passed', () {
        final ServiceProvider sp = ServiceProvider.fromFactory(
            'a', (final Public.Injector injector) => 'a',
            instantiationType: ServiceProviderInstantiationType.OnBoot,
            location: ServiceProviderLocation.Local);
        expect(sp.type, ServiceProviderType.Factory);
        expect(sp.location, ServiceProviderLocation.Local);
        expect(sp.instantiationType, ServiceProviderInstantiationType.OnBoot);
      });
    });

    group('constructor fromValue', () {
      test('It should create', () {
        expect(ServiceProvider.fromValue('a'), isNotNull);
      });

      test('It should throw an AssertionError, when the instance is null', () {
        expect(() => ServiceProvider.fromValue(null), throwsAssertionError);
      });

      test('It should set the default properties correctly', () {
        final ServiceProvider sp = ServiceProvider.fromValue('a');

        expect(sp.location, ServiceProviderLocation.Root);
        expect(sp.instantiationType, ServiceProviderInstantiationType.OnBoot);
      });

      test('It should assign the properties correctly, when passed', () {
        final ServiceProvider sp = ServiceProvider.fromValue('a',
            location: ServiceProviderLocation.Root);

        expect(sp.dependencies.length, 0);
        expect(sp.instantiationType, ServiceProviderInstantiationType.OnBoot);
        expect(sp.type, ServiceProviderType.Value);
        expect(sp.location, ServiceProviderLocation.Root);
      });
    });
  });

  group('instantiateServiceFromProvider()', () {
    test('It should return the value unmodified, when created fromValue', () {
      const String instance = 'AaA';

      final ServiceProvider sp = ServiceProvider.fromValue(instance,
          location: ServiceProviderLocation.Root);

      expect(instantiateServiceFromProvider(sp, null), instance);
    });

    test(
        'It should call the factory method and return the correct instance, when created fromFactory',
        () {
      const String value = 'aAa';

      bool wasCalled = false;

      final FactoryProvider creation = (final Public.Injector injector) {
        wasCalled = true;

        return value;
      };

      final ServiceProvider sp = ServiceProvider.fromFactory('A', creation);

      final instanceValue = instantiateServiceFromProvider(sp, null);

      expect(wasCalled, true);
      expect(instanceValue, value);
    });
  });
}
