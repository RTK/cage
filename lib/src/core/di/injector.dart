part of cage.di;

/// the injector handles dependencies
///
/// dependencies (injectables) can be registered with an injection token and
/// will be retrieved using this injection token
///
/// an injector must have a parent injector (exception: root injector / empty)
/// and will adopt all of the parent's dependencies
///
/// dependencies retrieved from the parent can be overriden using the same
/// injection token
@protected
class Injector {
  static final Injector _emptyInjector = Injector(null);

  static const InjectionToken _injectionToken = InjectionToken('Injector');

  @protected
  final Map<String, Object> _dependencies = Map();

  final Injector _parent;

  @protected
  Injector(this._parent) {
    if (_parent != null && _parent._dependencies.length > 0) {
      _dependencies.addAll(_parent._dependencies);
    }

    registerDependency(_injectionToken, this);
  }

  @protected
  @visibleForTesting
  void registerDependency(InjectionToken token, Object injectable) {
    _dependencies[token.token] = injectable;
  }

  /// retrieves a dependency from the stored injectors
  ///
  /// if a dependency is not registered an exception is thrown
  T getDependency<T extends Object>(InjectionToken injectionToken) {
    final String token = injectionToken.token;

    if (!_dependencies.containsKey(token)) {
      throw 'Dependency $token is not registered';
    }

    return _dependencies[token];
  }
}

Injector emptyInjector = Injector._emptyInjector;
