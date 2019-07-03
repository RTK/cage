// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:meta/meta.dart';

import 'action.dart';
import 'feeder.dart';
import 'mutation.dart';
import 'state.dart';
import 'store.dart';
import 'transaction_tokens.dart';

/// Helper class to instantiate a [Store] with [Action]s, [Mutation]s and
/// [Feeder]s.
class StoreModuleInstantiator<S extends State> {
  /// References the internal [Store].
  final Store<S> _store;

  /// Public constructor for [StoreModuleInstantiator].
  ///
  /// Takes a [Store], which will be bootstrapped.
  ///
  /// Optionally takes a [List] of [Pairwise] objects for [Action]s and
  /// [Mutation]s. Also takes a [List] of [Feeder]s.
  ///
  /// Iterates over the [actions] and adds each [Action] with its [ActionToken]
  /// to the [_store].
  ///
  /// Iterates over the [mutations] and adds each [Mutation] with its
  /// [MutationToken] to the [_store].
  ///
  /// Adds each [Feeder] from [feeders] to the [_store].
  StoreModuleInstantiator(this._store,
      {List<Pairwise<ActionToken, Action>> actions,
      List<Feeder> feeders,
      List<Pairwise<MutationToken, Mutation>> mutations})
      : assert(_store != null) {
    if (actions != null && actions.isNotEmpty) {
      for (final Pairwise<ActionToken, Action> pairwise in actions) {
        _store.addAction(pairwise.token, pairwise.object);
      }
    }

    if (mutations != null && mutations.isNotEmpty) {
      for (final Pairwise<MutationToken, Mutation> pairwise in mutations) {
        _store.addMutation(pairwise.token, pairwise.object);
      }
    }

    if (feeders != null && feeders.isNotEmpty) {
      for (final Feeder feeder in feeders) {
        _store.addFeeder(feeder);
      }
    }
  }
}

/// Helper class to store a generic type token and a generic type object.
///
/// Marked immutable.
@immutable
class Pairwise<T, O> {
  final T token;

  final O object;

  @literal
  const Pairwise(this.token, this.object);
}
