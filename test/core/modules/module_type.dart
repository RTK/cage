// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:cage/src/_private.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ModuleType', () {
    test('It should create', () {
      expect(ModuleTypeImpl(const ModuleKey('test')), isNotNull);
    });

    test('It should throw an assertion error, when null is given as key', () {
      expect(() => ModuleTypeImpl(null), throwsAssertionError);
    });
  });
}

class ModuleTypeImpl extends ModuleType {
  ModuleTypeImpl(ModuleKey id) : super(id);

  @override
  // TODO: implement module
  Module get module => null;
}
