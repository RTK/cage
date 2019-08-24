// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.
import 'dart:async';

import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

export 'package:logging/logging.dart' show Level, Logger;

typedef _LogFn = void Function(Object object);

@visibleForTesting
StreamSubscription logSubscription;

@visibleForTesting
_LogFn logFn = print;

/// Enabled the logging mechanisms by accepting a [level].
/// Each record will be written via [print].
///
/// If logging has already been enabled, an [AssertionError] is thrown.
///
/// The Log-Format looks as follows: {level}: {timestamp}: {message}
void enableLogging([final Level level = Level.ALL]) {
  assert(logSubscription == null);

  Logger.root.level = level;

  logSubscription = Logger.root.onRecord.listen((final LogRecord logRecord) {
    logFn(
        '${logRecord.level.name} >> ${logRecord.time} >> ${logRecord.loggerName} >> : ${logRecord.message}');
  });
}

/// Creates a new [Logger] with given [name].
Logger createLogger(final String name) {
  return Logger(name);
}

/// Disables logging for all [Logger].
///
/// If logging is not enabled, an [AssertionError] is thrown.
void disableLogging() {
  assert(logSubscription != null);

  logSubscription.cancel();
}

@visibleForTesting
void reset() {
  if (logSubscription != null) {
    disableLogging();
  }

  logSubscription = null;
}
