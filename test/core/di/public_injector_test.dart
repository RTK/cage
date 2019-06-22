// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:cage/cage.dart' as Public;
import 'package:cage/src/_private.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Injector (public)', () {
    Injector injector;

    setUp(() {
      injector = emptyInjector.createChild(linkToParent: false);
    });

    test('It should create', () {
      expect(createPublicInjector(injector), isNotNull);
    });

    group('getDependency()', () {
      test('It should override the Injector dependency with itself', () {
        expect(injector.getDependency(Injector), injector);

        final Public.Injector publicInjector = createPublicInjector(injector);
        expect(publicInjector.getDependency(Injector), publicInjector);
      });

      test('It should retrieve all dependencies from the private injector', () {
        const InjectionToken token_a = InjectionToken('a');
        const InjectionToken token_b = InjectionToken('b');

        const String value_a = 'a';
        const String value_b = 'b';

        injector.registerDependency(Injectable(token_a, value_a));
        injector.registerDependency(Injectable(token_b, value_b));

        final Public.Injector publicInjector = createPublicInjector(injector);

        expect(publicInjector.getDependency(token_a), value_a);
        expect(publicInjector.getDependency(token_b), value_b);
      });
    });
  });
}
