// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart' show Key, Widget;
import 'package:meta/meta.dart';

import 'module_key.dart';
import 'module_type.dart';

@immutable
class Module extends ModuleType {
  final List<ModuleType> imports;

  final Widget rootWidget;

  final List<Object> services;

  final List<Object> widgets;

  @override
  Module get module => this;

  const Module(final ModuleKey id,
      {this.imports, this.rootWidget, this.services, this.widgets})
      : super(id);
}
