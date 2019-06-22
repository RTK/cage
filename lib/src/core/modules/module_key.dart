// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:meta/meta.dart';

@immutable
class ModuleKey {
  final String key;

  @literal
  const ModuleKey(this.key) : assert(key != null && key.length > 0);
}
