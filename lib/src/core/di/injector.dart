// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

abstract class Injector {
  T getDependency<T>(final Object injectionToken);
}
