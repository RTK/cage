// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:cage/src/_private.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Injectable', () {
    InjectionToken token;
    Object instance;

    setUp(() {
      token = const InjectionToken('Test');
      instance = Object();
    });

    tearDown(() {
      token = null;
      instance = null;
    });

    test('It shall create', () {
      Injectable injectable = Injectable(token, instance);

      expect(injectable, isNotNull);
    });

    test('It should provide access to instance and injectionToken', () {
      Injectable injectable = Injectable(token, instance);

      expect(injectable.instance, instance);
      expect(injectable.injectionToken, token);
    });
  });
}
