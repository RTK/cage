import 'package:cage/src/core/di/di.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('An injectionToken can be created', () {
    const String value = 'test';

    InjectionToken token = InjectionToken(value);

    expect(token, isNotNull);
    expect(token.token, value);
  });

  test('An injectionToken must not have an empty identifier', () {
    expect(() => InjectionToken(''), throwsA(anything));
  });
}
