// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:meta/meta.dart';

import 'state.dart';
import 'private_store.dart';

/// [Feeder]s are used to retrieve data from a [Store].
///
/// Feeders implement a getFeed method, which filters data from the [State].
abstract class Feeder<S extends State, V> {
  /// The [StreamController] is used to notify about [_state] changes and
  /// resulting in the [Feeder]'s output.
  @visibleForTesting
  final StreamController<V> streamController;

  /// Is called before each update via [_streamController].
  ///
  /// Can be overwritten to prevent updates under certain circumstances.
  bool get shouldUpdate => true;

  /// Public accessor for [_state].
  @mustCallSuper
  S get state => _state;

  @visibleForTesting
  Store<S> get store => _store;

  /// Returns the [Stream] from [_streamController], used to listen to all
  /// updates from this [Feeder].
  Stream<V> get updates => streamController.stream;

  /// Used to compare whenever the [_state] changes. When the [_state] changes,
  /// but this [Feeder]'s output is not affected, the [_streamController] should
  /// not update.
  V _previousOutput;

  /// References the current [State] from the [_store].
  S _state;

  /// References its [Store].
  Store<S> _store;

  /// Public constructor for [Feeder].
  ///
  /// Takes the optional parameter [offersStream] which defaults to true.
  /// If [offersStream] is true, the [_streamController] is initialized as
  /// broadcast [StreamController].
  Feeder([final bool offersStream = true])
      : streamController = offersStream ? StreamController.broadcast() : null;

  /// Method used to transform the [Feeder]'s data from the [_state].
  ///
  /// To be implemented.
  @visibleForOverriding
  V getFeed();

  /// Disposes the [Feeder].
  ///
  /// If the [Feeder] offers a stream via [updates], the [_streamController]
  /// is closed.
  ///
  /// Furthermore the [Feeder] is removed from the [_store].
  @mustCallSuper
  void dispose() {
    if (streamController != null) {
      streamController.close();
    }

    if (_store != null) {
      _store.removeFeeder(this);
    }
  }
}

/// Triggers a [State] change for given [feeder] with given [state].
///
/// If the [feeder] offers its data via [Stream], the [StreamController] is
/// updated with the transformed result from the [feeder].
void setFeederState(final Feeder feeder, final State state) {
  feeder._state = state;

  if (feeder.streamController != null) {
    dynamic output = feeder.getFeed();

    if (output != feeder._previousOutput && feeder.shouldUpdate) {
      feeder._previousOutput = output;

      feeder.streamController.sink.add(output);
    }
  }
}

/// Sets the [feeder]'s [store].
///
/// If the [feeder] already has a [Store] assigned, an [AssertionError] is thrown.
void setFeederStore(final Feeder feeder, final Store store) {
  assert(feeder._store == null || store == null);

  feeder._store = store;
}
