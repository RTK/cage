// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:meta/meta.dart';

/// Base class for all [State]s.
///
/// A store [State] is an immutable object containing data.
///
/// Is marked [immutable].
@immutable
abstract class State {
  @literal
  const State();
}
