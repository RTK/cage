// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'module.dart';
import 'module_key.dart';

abstract class ModuleType {
  final ModuleKey id;

  Module get module;

  const ModuleType(this.id) : assert(id != null);
}
