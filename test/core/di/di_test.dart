import 'package:cage/src/core/di/di.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('The package shall expose all public objects and classes', () {
    test('Injectable', () {
      expect(SingletonInjectableFactory, isNotNull);
    });

    test('Injection token', () {
      expect(InjectionToken, isNotNull);
    });

    test('Injector', () {
      expect(Injector, isNotNull);
      expect(emptyInjector, isNotNull);
    });
  });
}
