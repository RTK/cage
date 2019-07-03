// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:cage/cage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ModuleKey', () {
    test('It should create', () {
      expect(const ModuleKey('test'), isNotNull);
    });

    test('It should throw an assertion error, when null is given as key', () {
      expect(() => ModuleKey(null), throwsAssertionError);
    });

    test(
        'It should throw an assertion error, when an empty string is given as key',
        () {
      expect(() => ModuleKey(''), throwsAssertionError);
    });

    group('toString', () {
      test('It should return the correct value', () {
        expect(const ModuleKey('test').toString(), '<<test>>');
      });
    });
  });
}
