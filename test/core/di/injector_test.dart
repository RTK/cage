// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:cage/src/_private.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Injector (private)', () {
    Injector injector;

    setUp(() {
      injector = emptyInjector.createChild(linkToParent: false);
    });

    tearDown(() {
      injector = null;
    });

    test('It should exist an empty injector', () {
      expect(emptyInjector, isNotNull);
    });

    group('registerDependency()', () {
      test('It should provide itself as dependency for the Injector token', () {
        expect(injector.getDependency(Injector), injector);
      });

      test('Registering and retrieving dependencies should be possible', () {
        const InjectionToken injectionToken = InjectionToken('testIT');
        final TestInjectable testInjectable = TestInjectable();

        injector.registerDependency(Injectable(injectionToken, testInjectable));

        expect(
            injector.getDependency<TestInjectable>(injectionToken).a, 'test');
      });

      test(
          'It should throw, when overwriting a dependencing with the denyOverwrite flag',
          () {
        const InjectionToken token = InjectionToken('test');

        injector
            .registerDependency(Injectable(token, 'test', denyOverwrite: true));

        expect(() => injector.registerDependency(Injectable(token, 'text')),
            throwsException);
      });
    });

    group('inheritance', () {
      test(
          'It should retrieve dependencies from its parent when it cannot satisfy the request',
          () {
        const InjectionToken injectionToken = InjectionToken('injectable');

        final TestInjectable testInjectable = TestInjectable();

        injector.registerDependency(Injectable(injectionToken, testInjectable));

        final Injector childInjector = injector.createChild();

        expect(childInjector.getDependency(injectionToken), testInjectable);
      });

      test('It should overload its parents dependencies', () {
        const InjectionToken injectionToken = InjectionToken('injectable');

        final TestInjectable testInjectable = TestInjectable();
        final TestInjectableOverride testInjectableOverride =
            TestInjectableOverride();

        injector.registerDependency(Injectable(injectionToken, testInjectable));

        final Injector childInjector = injector.createChild();
        childInjector.registerDependency(
            Injectable(injectionToken, testInjectableOverride));

        expect(childInjector.getDependency(injectionToken),
            testInjectableOverride);
      });
    });

    group('hasDependency()', () {
      test('It should return false, if the dependency is not registered', () {
        expect(injector.hasDependency(const InjectionToken('test')), false);
      });

      test('It should return true, if the dependency is registered', () {
        const InjectionToken injectionToken = InjectionToken('test');

        injector.registerDependency(Injectable(injectionToken, 'test'));

        expect(injector.hasDependency(injectionToken), true);
      });
    });

    group('hasDependencies()', () {
      test('It should return false, if a single dependency cannot be found',
          () {
        const InjectionToken token_a = InjectionToken('a');
        const InjectionToken token_b = InjectionToken('b');
        const InjectionToken token_c = InjectionToken('c');

        injector.registerDependency(Injectable(token_a, 'a'));
        injector.registerDependency(Injectable(token_b, 'b'));

        expect(injector.hasDependencies([token_a, token_b, token_c]), false);
      });

      test('It should return true, if all dependencies can be found', () {
        const InjectionToken token_a = InjectionToken('a');
        const InjectionToken token_b = InjectionToken('b');
        const InjectionToken token_c = InjectionToken('c');

        injector.registerDependency(Injectable(token_a, 'a'));
        injector.registerDependency(Injectable(token_b, 'b'));
        injector.registerDependency(Injectable(token_c, 'c'));

        expect(injector.hasDependencies([token_a, token_b, token_c]), true);
      });
    });

    group('toString()', () {
      test('It should return the correct string', () {
        final Injectable injA = Injectable(const InjectionToken('a'), 'a');
        final Injectable injB = Injectable(const InjectionToken('b'), 'b');

        final Map<InjectionToken, Injectable> injectables = {
          Injector.token: Injectable(Injector.token, injector),
          const InjectionToken('a'): injA,
          const InjectionToken('b'): injB
        };

        injector.registerDependency(injA);
        injector.registerDependency(injB);

        expect(injector.toString(), injectables.toString());
      });
    });
  });
}

class TestInjectable {
  final String a = 'test';
}

class TestInjectableOverride {
  final String a = 'noTest';
}
