// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:cage/cage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Module', () {
    test('It should create', () {
      expect(Module(const ModuleKey('Test')), isNotNull);
    });
  });
}
