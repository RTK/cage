// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'feeder.dart';
import 'state.dart';
import 'store.dart' as Private;
import 'transaction_tokens.dart';

/// Accessor used to access certain functionalities from a [Store].
///
/// Is used to dispatch [Action]s and get [Feeder]s.
class Store<S extends State> {
  /// References the original, private [Store].
  final Private.Store<S> _store;

  Store._internal(this._store);

  /// Is used to dispatch the [actionToken] and the optional [payload] to the
  /// [_store].
  void dispatch<P>(final ActionToken actionToken, [final P payload]) {
    _store.dispatch<P>(actionToken, payload);
  }

  /// Is used to retrieve a [Feeder] with given type [F].
  List<F> getFeeder<F extends Feeder>() => _store.feeders
      .where((final Feeder feeder) => feeder is F)
      .cast<F>()
      .toList(growable: false);
}

/// Sets the [Store]'s internal [Store] to [store].
Store<S> createStoreModuleAccessor<S extends State>(
        final Private.Store<S> store) =>
    Store._internal(store);
