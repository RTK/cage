// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:cage/cage.dart';
import 'package:cage/runtime.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('TestRuntime class shall exsit', () {
    expect(TestRuntime, isNotNull);
  });

  group('Module bootstrapping', () {
    test('A TestCage instance shall be created', () {
      final Module module = Module(const ModuleKey('test'));

      expect(TestRuntime.bootstrapModule(module) is TestCage, true);
    });
  });
}
