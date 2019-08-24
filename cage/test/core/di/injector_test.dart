// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:cage/src/core/di/injector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Injector (interface)', () {
    test('It should create', () {
      expect(MyInjector(), isNotNull);
    });
  });
}

class MyInjector implements Injector {
  @override
  T getDependency<T>(Object injectionToken) {
    return null;
  }
}
