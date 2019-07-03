// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:cage/src/_private.dart';

class TestRuntime {
  static TestCage bootstrapModule(final ModuleType moduleType) {
    final Injector rootInjector = emptyInjector.createChild();

    final CagedModule cagedModule =
        CagedModule.fromModuleType(moduleType, rootInjector, null, null);

    cagedModule.bootstrap();

    final Cage cage = Cage.fromCagedModule(cagedModule);

    return TestCage(cage, rootInjector);
  }
}
