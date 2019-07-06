// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';

import '../../lib/src/services/text_service.dart';

void main() {
  group('TextService', () {
    group('generateRandomString()', () {
      test('It should return a string', () {
        expect(TextService().generateRandomString, isInstanceOf<String>());
      });
    });
  });
}
