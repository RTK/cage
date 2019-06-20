import 'package:cage/cage.dart' show CagedModule;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Creating an empty module with a key will not fail', () {
    CagedModule module = CagedModuleStub('Test');

    expect(module, isNotNull);
  });
}

class CagedModuleStub extends CagedModule {
  CagedModuleStub(String id) : super(id);
}
