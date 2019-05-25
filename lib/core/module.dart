part of cage.core;

class _ModuleEntry {
  final List<CagedModule> children;

  final CagedModule module;

  const _ModuleEntry(this.module, [this.children = const []]);
}

@protected
class ModuleRegistry {
  static final _instance = ModuleRegistry._internal();

  List<CagedModule> _modules = [];

  _ModuleEntry _moduleTree;

  factory ModuleRegistry() {
    return _instance;
  }

  ModuleRegistry._internal();

  registerModule(CagedModule module, bool isRootModule) {
    if (isRootModule && _moduleTree != null) {
      throw 'There is already a root module defined';
    }

    _moduleTree = _ModuleEntry(module);

    _modules.add(module);
  }
}

abstract class CagedModule {
  final String id;

  final Widget bootstrap;

  final List<Widget> declarations;

  final List<CagedModule> imports;

  // TODO add providers

  const CagedModule(this.id,
      {this.declarations: const [], this.imports: const [], this.bootstrap});
}
