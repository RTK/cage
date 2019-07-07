// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:cage/src/_private.dart';

class FlutterTestRuntime {
  /// Bootstraps a [ModuleType] to be used in test cases.
  static TestCage bootstrapModule(final ModuleType moduleType) {
    final Injector rootInjector = emptyInjector.createChild();

    final CagedModule cagedModule =
        CagedModule.fromModuleType(moduleType, rootInjector);

    cagedModule.bootstrap();

    final Cage cage = Cage.fromCagedModule(cagedModule);

    return TestCage(cage);
  }
}
