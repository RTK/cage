// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:cage/src/_private.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Envelope', () {
    test('It should create', () {
      expect(const Envelope(const ActionToken('test'), '123'), isNotNull);
    });

    test('It should throw when the action token is null', () {
      expect(() => Envelope(null), throwsAssertionError);
    });
  });
}
