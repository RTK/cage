// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:meta/meta.dart';

import 'envelope.dart';
import 'transaction_tokens.dart';

typedef _TransactionCallback = void Function(Envelope envelope);

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

  /// Factory constructor for [Dispatcher].
  ///
  /// Always returns the [_instance].
  factory Dispatcher() => _instance;

  /// Internal constructor
  Dispatcher._internal();

  /// Dispatches an action.
  ///
  /// Takes an [actionToken] and optionally a [payload] to be wrapped in an
  /// [Envelope].
  void dispatchAction<P>(final ActionToken actionToken, [final P payload]) {
    assert(!_subscriptionStream.isClosed && !_subscriptionStream.isPaused);

    _subscriptionStream.sink.add(Envelope<P>(actionToken, payload));
  }

  /// Registers a callback on [Dispatcher] events.
  ///
  /// Whenever the Dispatcher] dispatches an [Envelope], the [listenCallback]
  /// is called.
  ///
  /// The Method returns a [StreamSubscription], so the listener can cancel the
  /// [StreamSubscription].
  StreamSubscription<Envelope> listenToDispatcher(
      final _TransactionCallback listenCallback) {
    assert(!_subscriptionStream.isClosed && !_subscriptionStream.isPaused);

    return Dispatcher()._subscriptionStream.stream.listen(listenCallback);
  }

  void _dispose() {
    assert(!_subscriptionStream.isClosed);

    _subscriptionStream.close();
  }
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
