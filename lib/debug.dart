// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

library cage.debug;

import 'src/_private.dart';

export 'src/debugging/_public.dart';

void enableDebugMode({final Level logLevel: Level.OFF}) {
  enableLogging(logLevel);
}
