//  Copyright Rouven T. Kruse. All rights reserved.
//  Use of this source code is governed by an MIT-style license that can be
//  found in the LICENSE file.

import 'package:cage/src/debugging/_internal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(reset);

  tearDown(reset);

  group('enableLogging()', () {
    test('It should throw an AssertionError, when logging already is enabled',
        () {
      enableLogging();

      expect(() => enableLogging(), throwsAssertionError);
    });
  });

  group('createLogger()', () {
    test('It should return a Logger', () {
      expect(createLogger('test'), isNotNull);
      expect(createLogger('test') is Logger, true);
    });

    test('It should return identical instances when identical names are passed',
        () {
      expect(createLogger('a'), createLogger('a'));
    });
  });

  group('disableLogging()', () {
    test('It should throw an AssertionError, when logging already is disabled',
        () {
      expect(() => disableLogging(), throwsAssertionError);
    });
  });

  group('logging', () {
    test('It should call the log method', () async {
      bool wasCalled = false;

      logFn = (Object obj) {
        wasCalled = true;
      };

      final Logger logger = createLogger('Test');

      enableLogging();

      logger.info('test');

      expect(wasCalled, true);

      disableLogging();
    });
  });
}
