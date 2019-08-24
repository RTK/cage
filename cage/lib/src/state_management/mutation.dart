// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:meta/meta.dart';

import 'state.dart';
import 'private_store.dart';
import 'transaction_tokens.dart';

/// A [Mutation] is used to mutate a [State].
///
/// The [Mutation] must implement a mutate method which returns a new [State].
abstract class Mutation<S extends State, P> {
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
  MutationToken get token => _token;

  /// References the [State] from its [_store].
  S _state;

  /// References its [Store].
  Store<S> _store;

  /// References its associated [MutationToken] to unregister from its [_store]
  /// when disposed.
  MutationToken _token;

  /// Disposes the [Mutation].
  ///
  /// Unregisters from [_store].
  @mustCallSuper
  void dispose() {
    if (_store != null) {
      _store.removeMutation(_token, this);
    }
  }

  /// Mutate method, called when ever a action commits with a [MutationToken]
  /// which equals to the [_token].
  ///
  /// Must return a [State].
  ///
  /// Receives an optional [payload] from the action for mutation.
  ///
  /// To be implemented.
  @visibleForOverriding
  S mutate([final P payload]);
}

/// Sets the [mutation]'s internal [State] to [state].
void setMutationState<S extends State>(final Mutation mutation, final S state) {
  mutation._state = state;
}

/// Sets the [mutation]'s [Store]to [store].
///
/// If the [Store] already has been assigned, an [AssertionError] is thrown.
void setMutationStore(final Mutation mutation, final Store store) {
  assert(mutation._store == null || store == null);

  mutation._store = store;
}

/// Sets the [mutation]'s [MutationToken] to [mutationToken].
///
/// If the [MutationToken] already has been assigned, an [AssertionError] is
/// thrown.
void setMutationToken(
    final Mutation mutation, final MutationToken mutationToken) {
  assert(mutation._token == null);

  mutation._token = mutationToken;
}
