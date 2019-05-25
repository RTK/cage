import 'package:cage/core/di/di.dart';
import 'package:flutter_test/flutter_test.dart';

int injectableCounter = 0;

void main() {
  final String moduleId = 'test';

  group('Singleton injectable factory', () {
    test('The factory shall create an injectable', () {
      injectableCounter = 0;

      final SingletonInjectableFactoryMock factory =
          SingletonInjectableFactoryMock(emptyInjector);

      Object factoryResult = factory.createInjectable(moduleId);

      expect(factoryResult, isNotNull);
      expect(factoryResult, isInstanceOf<InjectableMock>());
    });

    test('The factory shall always return the firstly created object', () {
      injectableCounter = 0;

      final SingletonInjectableFactoryMock factory =
          SingletonInjectableFactoryMock(emptyInjector);

      InjectableMock factoryResult = factory.createInjectable(moduleId);
      final int counter = factoryResult.counter;

      expect(factoryResult.counter, counter);

      for (int i = 0; i < 10; i++) {
        expect(factory.createInjectable(moduleId).counter, counter);
      }

      expect(InjectableMock().counter, 1);
    });
  });
}

class SingletonInjectableFactoryMock extends SingletonInjectableFactory {
  SingletonInjectableFactoryMock(Injector injector) : super(injector);

  @override
  Object getInjectable() => InjectableMock();
}

class InjectableMock {
  final int counter;

  InjectableMock() : counter = injectableCounter++;
}
