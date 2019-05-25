import 'package:cage/core/di/di.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('An empty injector shall exist', () {
    expect(emptyInjector, isNotNull);
  });

  group('Registering dependencies', () {
    test('A injector shall provide itself as dependency', () {
      final Injector ti = Injector(emptyInjector);

      expect(ti.getDependency(InjectionToken('Injector')), ti);
    });

    test('A dependency can be registered and retrieved', () {
      final InjectionToken injectionToken = InjectionToken('testIT');

      final Injector ti = Injector(emptyInjector);

      final TestInjectable testInjectable = TestInjectable();

      ti.registerDependency(injectionToken, testInjectable);

      expect(ti.getDependency<TestInjectable>(injectionToken).a, 'test');
    });
  });

  group('Injector inheritance', () {
    test('A child injector shall inherit all dependencies', () {
      final InjectionToken injectionToken = InjectionToken('injectable');
      final TestInjectable testInjectable = TestInjectable();

      final Injector parentInjector = Injector(emptyInjector);
      parentInjector.registerDependency(injectionToken, testInjectable);

      final Injector childInjector = Injector(parentInjector);

      expect(childInjector.getDependency(injectionToken), testInjectable);
    });

    test('A child can override dependencies', () {
      final InjectionToken injectionToken = InjectionToken('injectable');
      final TestInjectable testInjectable = TestInjectable();
      final TestInjectableOverride testInjectableOverride =
          TestInjectableOverride();

      final Injector parentInjector = Injector(emptyInjector);
      parentInjector.registerDependency(injectionToken, testInjectable);

      final Injector childInjector = Injector(parentInjector);
      childInjector.registerDependency(injectionToken, testInjectableOverride);

      expect(
          childInjector.getDependency(injectionToken), testInjectableOverride);
    });
  });
}

class TestInjectable {
  final String a = 'test';
}

class TestInjectableOverride {
  final String a = 'noTest';
}
