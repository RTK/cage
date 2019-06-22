// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart' show Key, Widget;
import 'package:meta/meta.dart';

import 'module_key.dart';
import 'module_type.dart';

/// Class to be used to define services and widgets.
///
/// A [Module] can import other modules and gain access to its services and
/// widgets, if they are not provided locally.
///
/// If the Module is used as entry point for the application, [rootWidget] must
/// be set, else an [Error] is thrown.
///
/// [Module] extends [ModuleType] thus calling the super's constructor with
/// the constructor's [id] parameter and implementing the [module] getter
/// method.
@immutable
class Module extends ModuleType {
  final List<ModuleType> imports;

  final Widget rootWidget;

  final List<Object> services;

  final List<Widget> widgets;

  @override
  Module get module => this;

  /// The constructor can be called as const constructor
  const Module(final ModuleKey id,
      {this.imports, this.rootWidget, this.services, this.widgets})
      : super(id);
}
