// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:cage/cage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('It should create', () {
    expect(State, isNotNull);
    expect(MyState(), isNotNull);
  });
}

class MyState extends State {}
