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
        const TransactionToken tt = const TransactionToken('test');

        expect(tt, tt);
        expect(const TransactionToken('test'), const TransactionToken('test'));
      });

      test(
          'It should return true if different instances with the same key are compared',
          () {
        const TransactionToken tt = const TransactionToken('test');

        expect(tt == tt, true);
        expect(const TransactionToken('test') == const TransactionToken('test'),
            true);
      });
    });

    group('toString()', () {
      test('It should return the value', () {
        expect(const TransactionToken('test').toString(), 'test');
      });
    });
  });

  group('ActionToken', () {
    test('It should create', () {
      expect(const ActionToken('token'), isNotNull);
    });

    group('toString()', () {
      test('It should return the correct value', () {
        expect(const ActionToken('test').toString(), 'ActionToken <test>');
      });
    });
  });

  group('MutationToken', () {
    test('It should create', () {
      expect(const MutationToken('token'), isNotNull);
    });

    test('It should return the correct value', () {
      expect(const MutationToken('test').toString(), 'MutationToken <test>');
    });
  });

  test(
      'An ActionToken and a MutationToken with equal value should not be equal',
      () {
    expect(const ActionToken('a') == const MutationToken('a'), false);
  });
}
