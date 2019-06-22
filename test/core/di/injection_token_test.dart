// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:cage/cage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InjectionToken', () {
    test('It should create', () {
      const String value = 'test';

      InjectionToken token = const InjectionToken(value);

      expect(token, isNotNull);
      expect(token.token, value);
    });

    test('It should throw an AssertionError, when given value is empty', () {
      expect(() => InjectionToken(''), throwsAssertionError);
    });

    group('operator==()', () {
      test('It should return true for non identical tokens with the same value',
          () {
        expect(const InjectionToken('a'), const InjectionToken('a'));
      });

      test('It should return false for everything else', () {
        expect(const InjectionToken('a') == 'a', false);
      });
    });
  });

  group('generateRuntimeInjectionToken()', () {
    test('It should return an instance of InjectionToken', () {
      InjectionToken token = const InjectionToken('test');

      expect(token, generateRuntimeInjectionToken(token));
    });

    test('It should throw an assertion error, when null is given', () {
      expect(() => generateRuntimeInjectionToken(null), throwsAssertionError);
    });

    test('It should use the parameter as token reference value', () {
      InjectionToken token = generateRuntimeInjectionToken('test');

      expect(token.token, 'test');
    });

    test(
        'It should call the toString method, when a non-string object is given ',
        () {
      InjectionToken token = generateRuntimeInjectionToken(TestClass);

      expect(token.token, 'TestClass');
    });
  });
}

class TestClass {}