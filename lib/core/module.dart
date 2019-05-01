import 'package:flutter/widgets.dart';

export 'package:flutter/widgets.dart' show Key;

class CagedModule {
  final Key id;

  // TODO replace with CagedWidget
  final Widget bootstrap;

  final List<CagedModule> imports;

  // TODO add providers
  CagedModule(this.id, {this.imports, this.bootstrap});
}
