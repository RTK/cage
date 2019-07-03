// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:meta/meta.dart';

/// A [ModuleKey] is used by modules and module types to be identified later on.
///
/// For identification a string value is used which must not be null nor empty.
@immutable
class ModuleKey {
  final String key;

  /// Constructor must be called as const.
  @literal
  const ModuleKey(this.key) : assert(key != null && key.length > 0);

  @override
  String toString() {
    return '<<$key>>';
  }
}
