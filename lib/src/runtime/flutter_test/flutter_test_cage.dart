// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:cage/src/_private.dart';

const Symbol defaultNotFoundValue = const Symbol('noValueGiven');

class TestCage {
  final Cage _cage;

  final Injector _injector;

  TestCage(this._cage, this._injector);

  T get<T>(final Object token,
      [final dynamic notFoundValue = defaultNotFoundValue]) {
    try {
      return _injector.getDependency(token);
    } catch (e) {
      if (notFoundValue != defaultNotFoundValue) {
        return notFoundValue;
      }

      rethrow;
    }
  }

  @override
  String toString() {
    return 'Test cage of <$_cage>';
  }
}
