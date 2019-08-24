// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:meta/meta.dart';

import 'transaction_tokens.dart';

/// Wraps an [ActionToken] and a payload to be broadcasted over the
/// [Dispatcher].
@immutable
class Envelope<P> {
  final ActionToken actionToken;

  final P payload;

  @literal
  const Envelope(this.actionToken, [this.payload])
      : assert(actionToken != null);
}
