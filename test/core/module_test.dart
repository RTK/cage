import 'package:cage/core/module.dart' show CagedModule, Key;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Creating an empty module with a key will not fail', () {
    CagedModule module = CagedModule(Key('Test'));

    expect(module, isNotNull);
  });
}
