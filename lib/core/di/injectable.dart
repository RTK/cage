part of cage.di;

@protected
abstract class _InjectableFactory<T> {
  final Injector injector;

  @mustCallSuper
  _InjectableFactory(this.injector);

  @factory
  T createInjectable(String sourceModule);
}

/// the singleton injectable factory creates an injectable
/// always returns the first created instance
abstract class SingletonInjectableFactory<T> extends _InjectableFactory<T> {
  T _instance;

  SingletonInjectableFactory(Injector injector) : super(injector);

  @override
  T createInjectable(String sourceModule) {
    if (_instance == null) {
      _instance = getInjectable();
    }

    if (_instance == null) {
      throw 'Injectable must not be null';
    }

    return _instance;
  }

  @factory
  @protected
  T getInjectable();
}
