// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:cage/debug.dart';
import 'package:cage/src/_private.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() {
    reset();
  });

  group('enableDebugMode()', () {
    test('It should enable logging with the correct log level', () {
      enableDebugMode(logLevel: Level.FINEST);

      expect(logSubscription, isNotNull);
      expect(Logger.root.level, Level.FINEST);
    });
  });
}
