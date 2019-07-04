// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:cage/src/_private.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('class TransactionToken', () {
    test('It should create', () {
      expect(const TransactionToken('test'), isNotNull);
    });

    test('It should throw, when given value is null', () {
      expect(() => TransactionToken(null), throwsAssertionError);
    });

    test('It should throw, when given value string is empty', () {
      expect(() => TransactionToken(''), throwsAssertionError);
    });

    group('operator ==()', () {
      test('It should compare the values when a CommitToken is passed', () {
        expect(const TransactionToken('test'), const TransactionToken('test'));
      });

      test('It should return false otherwise', () {
        expect(const TransactionToken('test') == 123, false);
      });
    });

    group('toString()', () {
      test('It should return the value', () {
        expect(const ActionToken('test').toString(), isNotNull);
      });
    });
  });

  group('ActionToken', () {
    test('It should create', () {
      expect(const ActionToken('token'), isNotNull);
    });
  });

  group('MutationToken', () {
    test('It should create', () {
      expect(const MutationToken('token'), isNotNull);
    });
  });

  test(
      'An ActionToken and a MutationToken with equal value should not be equal',
      () {
    expect(const ActionToken('a') == const MutationToken('a'), false);
  });
}
