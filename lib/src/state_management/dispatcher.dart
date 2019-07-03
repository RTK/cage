// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:meta/meta.dart';

import 'transaction_tokens.dart';

typedef TransactionCallback = void Function(Envelope envelope);

/// Global [Dispatcher].
///
/// The [Dispatcher] is used to trigger [Action]s. For doing so it uses
/// [ActionToken]s.
class Dispatcher {
  /// Holds the instance of the [Dispatcher], Singleton pattern.
  static Dispatcher _instance = Dispatcher._internal();

  /// The [StremController] is used to broadcast [Envelope]s (events).
  final StreamController<Envelope> _subscriptionStream =
      StreamController.broadcast();

  /// Dispatches an action.
  ///
  /// Takes an [actionToken] and optionally a [payload] to be wrapped in an
  /// [Envelope].
  void dispatchAction<P>(final ActionToken actionToken, [final P payload]) {
    _subscriptionStream.sink.add(Envelope<P>(actionToken, payload));
  }

  void _dispose() {
    _subscriptionStream.close();
  }

  /// Factory constructor for [Dispatcher].
  ///
  /// Always returns the [_instance].
  factory Dispatcher() => _instance;

  /// Internal constructor
  Dispatcher._internal();
}

/// Wraps an [ActionToken] and a payload to be broadcasted over the
/// [Dispatcher].
@immutable
class Envelope<P> {
  final ActionToken actionToken;

  final P payload;

  @literal
  const Envelope(this.actionToken, this.payload);
}

/// This function is used to listen to the [Dispatcher]. Whenever the
/// [Dispatcher] dispatches an [Envelope], the [listenCallback] is called.
///
/// Method returns a [StreamSubscription], so the listener can cancel the
/// [StreamSubscription].
StreamSubscription<Envelope> listenToDispatcher(
    final TransactionCallback listenCallback) {
  return Dispatcher()._subscriptionStream.stream.listen(listenCallback);
}

/// This function is used to dispose the global [Dispatcher].
///
/// It calls the internal dispose method and returns the [StreamController]
/// used to broadcast events.
StreamController<Envelope> disposeDispatcher() {
  Dispatcher()._dispose();

  return Dispatcher()._subscriptionStream;
}

/// Resets the [Dispatcher] instance with a new one.
///
/// Used for testing purposes only.
@visibleForTesting
void resetDispatcher() {
  Dispatcher._instance = Dispatcher._internal();
}
