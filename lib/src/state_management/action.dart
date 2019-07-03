// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.
import 'package:meta/meta.dart';

import 'state.dart';
import 'store.dart';
import 'transaction_tokens.dart';

/// An [Action] is used to be registered onto a [Store].
///
/// When a [Transaction] from the application is rised, each [Action] with the
/// corresponding [actionToken] will trigger its [execute] method.
abstract class Action<S extends State, P> {
  /// Function used to apply commits to the [_store].
  @visibleForTesting
  Function applyCommit = applyStoreCommit;

  /// Returns the [_state].
  S get state => _state;

  /// Returns the [_store].
  ///
  /// For testing purposes only.
  @visibleForTesting
  Store<S> get store => _store;

  /// Returns the [_token].
  ///
  /// For testing purposes only.
  @visibleForTesting
  ActionToken get token => _token;

  S _state;

  /// References the [Store] to deregister when disposed.
  Store<S> _store;

  /// The [_token] is used to remove this instance from its [_store] when
  /// disposed.
  ActionToken _token;

  /// Commits the [mutationToken] to the [_store] with optional [payload].
  @mustCallSuper
  void commit(final MutationToken mutationToken, [final dynamic payload]) {
    applyCommit(_store, mutationToken, payload);
  }

  /// Disposes the [Action].
  ///
  /// Removes the [Action] from the [_store].
  @mustCallSuper
  void dispose() {
    if (_store != null) {
      _store.removeAction(_token, this);
    }
  }

  /// The execute method is triggered by the [Action]'s [_store].
  ///
  /// Receives an optional [payload].
  ///
  /// To be implemented.
  @visibleForOverriding
  void execute([final P payload]);
}

/// Sets the [action]'s [State] to [state].
void setActionState<S extends State>(final Action action, final S state) {
  action._state = state;
}

/// Sets the [action]'s [Store] with given [store] value.
///
/// If a [Store] already is assigned, an [AssertionError] is thrown.
void setActionStore(final Action action, final Store store) {
  assert(action._store == null || store == null);

  action._store = store;
}

/// Assigns the [actionToken] to given [action].
///
/// If the [action] already has a token set, a [AssertionError] is thrown.
void setActionToken(final Action action, final ActionToken actionToken) {
  assert(action._token == null);

  action._token = actionToken;
}
