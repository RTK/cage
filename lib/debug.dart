// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

library cage.debug;

import 'src/debugging/_public.dart';

export 'src/debugging/_public.dart' show createLogger, Logger, Level;

void enableDebugMode({final Level logLevel: Level.OFF}) {
  enableLogging(logLevel);
}
