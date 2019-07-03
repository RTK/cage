// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:cage/cage.dart' as Public show Injector;
import 'package:cage/src/_private.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TestCage', () {
    Injector injector;

    setUp(() {
      injector = emptyInjector.createChild(linkToParent: false);
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

        final TestCage testCage = TestCage(cage, injector);

        expect(testCage.get(TestService), isNotNull);
      });

      test('It should return the notFound value for the dependency', () {
        final Module module = Module(const ModuleKey('test'));

        final CagedModule cagedModule =
            CagedModule.fromModuleType(module, injector);

        cagedModule.bootstrap();

        final Cage cage = Cage.fromCagedModule(cagedModule);

        final TestCage testCage = TestCage(cage, injector);

        expect(testCage.get('Test123', 'test123'), 'test123');
      });

      test(
          'It should throw an error, when the dependency cannot be found and no default value is provided',
          () {
        final Module module = Module(const ModuleKey('test'));

        final CagedModule cagedModule =
            CagedModule.fromModuleType(module, injector);

        cagedModule.bootstrap();

        final Cage cage = Cage.fromCagedModule(cagedModule);

        final TestCage testCage = TestCage(cage, injector);

        expect(() => testCage.get('Test123'), throwsException);
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

        final TestCage testCage = TestCage(cage, injector);

        expect(testCage.toString(), 'Test cage of <Cage of <<test>>>');
      });
    });
  });
}

class TestService {}
