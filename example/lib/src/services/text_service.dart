// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.
import 'dart:math';

class TextService {
  final Random _random = Random();

  String generateRandomString() {
    return 'Count? ${_random.nextInt(100)}';
  }
}
