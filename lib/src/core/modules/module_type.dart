// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'module.dart';
import 'module_key.dart';

/// Abstraction layer for [Module] class.
///
/// Defines an [id] and a getter method [module] which must be implemented by
/// child structures.
abstract class ModuleType {
  final ModuleKey id;

  Module get module;

  /// Can be calles as const constructor.
  const ModuleType(this.id) : assert(id != null);
}
