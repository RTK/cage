// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:cage/cage.dart' as Public show Injector;
import 'package:cage/src/_private.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Injector injector;

  setUp(() {
    injector = emptyInjector.createChild(linkToParent: false);
  });

  group('Retriving dependencies', () {
    test('Getting dependencies from TestCage shall be possible', () {
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
  });
}

class TestService {}
