// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.
import 'dart:async';

import 'package:meta/meta.dart';

import 'action.dart';
import 'dispatcher.dart';
import 'feeder.dart';
import 'mutation.dart';
import 'state.dart';
import 'transaction_tokens.dart';

import '../debugging/_private.dart';

/// A [Store] represents an entity for storing data.
///
/// The [Store]'s data is represented by a [State] ([_state]). The [_state] is
/// immutable and can only be mutated by [Mutation]s.
///
/// [Mutation]s are triggered by committing a [MutationToken] to the store. A
/// store commit will trigger each [Action] registered for the
/// [MutationToken] provided within the commit.
///
/// An [Action] will cause a [Mutation]. A [Mutation] results in a changed
/// [State].
class Store<S extends State> {
  /// References all registered [Action]s by associating the instances via
  /// [ActionToken].
  final Map<ActionToken, List<Action>> actions = Map();

  /// References all registered [Feeder]s in a [List].
  final List<Feeder> feeders = [];

  /// References all registered [Mutation]s by associating the instances
  /// via [MutationToken].
  final Map<MutationToken, List<Mutation>> mutations = Map();

  final Logger _logger = createLogger('Store');

  /// References the [StreamSubscription] to the global [Dispatcher].
  ///
  /// Is used to cancel the [StreamSubscription], when [dispose] is called.
  @visibleForTesting
  StreamSubscription<Envelope<dynamic>> dispatcherSubscription;

  /// Flag that indicates, that the store has been disposed.
  bool _isDisposed = false;

  /// Flag that indicates, that the store is in the disposing process.
  ///
  /// Is used to prevent the [removeAction], [removeMutation] and [removeFeeder]
  /// methods to remove the specific object from any list, since the lists
  /// will be cleared afterwards anyways.
  bool _isDisposing = false;

  /// References the internal state [S]. The state is immutable.
  S _state;

  /// Initializes a [Store] by accepting an initial [State] as argument.
  ///
  /// If the [_state] is null, an [AssertionError] is thrown.
  ///
  /// Initializes the [Action]s, [Feeder]s and [Mutation]s if provided.
  ///
  /// If the [ignoreGlobalDispatcher] argument resolves to false, the [Store]
  /// listens to [Envelope] events dispatched by the global [Dispatcher].
  ///
  /// Refreshes each [Feeder] registered afterwards with [_refreshFeeders] so
  /// they process the initial [_state].
  @mustCallSuper
  Store(this._state, {bool ignoreGlobalDispatcher = false})
      : assert(_state != null) {
    _logger.config('Initializing store');

    if (!ignoreGlobalDispatcher) {
      dispatcherSubscription = listenToDispatcher((final Envelope envelope) {
        dispatch(envelope.actionToken, envelope.payload);
      });
    }

    _refreshFeeders();
  }

  /// Adds a [Action] to the store.
  ///
  /// Adds given [action] to the [Action] list associated with the
  /// [actionToken].
  ///
  /// Sets the [action]'s [Store] to this instance.
  /// Updates the [action]'s [ActionToken] to [actionToken].
  @mustCallSuper
  void addAction(final ActionToken actionToken, final Action action) {
    assert(!_isDisposed);

    _logger.info('Add action with token $actionToken');

    if (!actions.containsKey(actionToken)) {
      actions[actionToken] = [];
    }

    actions[actionToken].add(action);

    setActionStore(action, this);
    setActionToken(action, actionToken);
  }

  /// Adds a [Feeder] to the store.
  ///
  /// Adds given [feeder] to the [Feeder] list.
  ///
  /// Sets the [feeder]'s [Store] to this instance.
  /// Sets the [feeder]'s [State] to [_state].
  @mustCallSuper
  void addFeeder(final Feeder feeder) {
    assert(!_isDisposed);

    _logger.info('Add feeder');

    feeders.add(feeder);

    setFeederStore(feeder, this);
    setFeederState(feeder, _state);
  }

  /// Adds a [Mutation] to the store.
  ///
  /// Adds given [mutation] to the corresponding list associated with the
  /// [mutationToken].
  ///
  /// Sets the [mutation]'s store to this instance.
  /// Sets the [mutation]'s [MutationToken] to [mutationToken].
  @mustCallSuper
  void addMutation(final MutationToken mutationToken, final Mutation mutation) {
    assert(!_isDisposed);

    _logger.info('Add mutation with token $mutationToken');

    if (!mutations.containsKey(mutationToken)) {
      mutations[mutationToken] = [];
    }

    mutations[mutationToken].add(mutation);

    setMutationStore(mutation, this);
    setMutationToken(mutation, mutationToken);
  }

  /// Dispatches given [payload] to each [Action] registered onto this
  /// [Store] with the corresponding [actionToken].
  ///
  /// Before executing the [Action]s, the [Action]'s [State] is refreshed with
  /// [_state].
  ///
  /// The execute method of each [Action] is called with the payload.
  @mustCallSuper
  void dispatch<P>(final ActionToken actionToken, [final P payload]) {
    assert(!_isDisposed);

    _logger.info(
        'Dispatching to actions with token $actionToken and payload $payload');

    if (actions.isNotEmpty && actions.containsKey(actionToken)) {
      for (final Action action in actions[actionToken]) {
        _logger.info('Executing action $action');

        setActionState(action, _state);

        action.execute(payload);
      }
    } else {
      _logger.info('No actions registered for token $actionToken');
    }
  }

  /// Disposes the store.
  ///
  /// Cancels the [Dispatcher] subscription if established.
  ///
  /// Calls the dispose method of each [Action], [Feeder] and [Mutation]
  /// associated to this [Store].
  @mustCallSuper
  void dispose() {
    assert(!_isDisposed);

    _logger.info('Disposing...');

    _isDisposing = true;

    if (dispatcherSubscription != null) {
      dispatcherSubscription.cancel();
    }

    for (final ActionToken actionToken in actions.keys) {
      for (final Action action in actions[actionToken]) {
        removeAction(actionToken, action);
      }
    }

    actions.clear();

    for (final Feeder feeder in feeders) {
      removeFeeder(feeder);
    }

    feeders.clear();

    for (final MutationToken mutationToken in mutations.keys) {
      for (final Mutation mutation in mutations[mutationToken]) {
        removeMutation(mutationToken, mutation);
      }
    }

    mutations.clear();

    _isDisposed = true;

    _logger.info('Disposing complete. Goodbye.');
  }

  /// Removes an [Action] from the store.
  ///
  /// Looks for the corresponding [Action] for passed in [action] and
  /// removes the entry, if found.
  @mustCallSuper
  void removeAction(final ActionToken actionToken, final Action action) {
    assert(!_isDisposed);

    _logger.info('Remove action with token $actionToken');

    setActionStore(action, null);

    action.dispose();

    if (!_isDisposing && actions.containsKey(actionToken)) {
      actions[actionToken]
          .removeWhere((final Action listAction) => listAction == action);

      if (actions[actionToken].isEmpty) {
        actions.removeWhere(
            (final ActionToken listToken, final List<Action> listActions) =>
                listToken == actionToken);
      }
    }
  }

  /// Removes a [Feeder] from the store.
  ///
  /// Looks for the corresponding [Feeder] for passed in [feeder] and
  /// removes the entry, if found.
  @mustCallSuper
  void removeFeeder(final Feeder feeder) {
    assert(!_isDisposed);

    _logger.info('Remove feeder');

    setFeederStore(feeder, null);
    feeder.dispose();

    if (!_isDisposing) {
      feeders.removeWhere((final Feeder listFeeder) => listFeeder == feeder);
    }
  }

  /// Removes a [Mutation] from the store.
  ///
  /// Looks for the corresponding [Mutation] for passed in [mutation] and
  /// removes the entry, if found.
  @mustCallSuper
  void removeMutation(
      final MutationToken mutationToken, final Mutation mutation) {
    assert(!_isDisposed);

    _logger.info('Remove mutation with token $mutationToken');

    setMutationStore(mutation, null);
    mutation.dispose();

    if (!_isDisposing && mutations.containsKey(mutationToken)) {
      mutations[mutationToken].removeWhere(
          (final Mutation listMutation) => listMutation == mutation);

      if (mutations[mutationToken].isEmpty) {
        mutations.removeWhere((final MutationToken listToken,
                final List<Mutation> listMutations) =>
            listToken == mutationToken);
      }
    }
  }

  /// Applies store [Mutation]s, caused by a comit from an [Action].
  ///
  /// Triggers all [Mutation]s registered for the [MutationToken] passed in
  /// by the a commit from an [Action]. Beforehand updates each [Mutation]'s
  /// [State] with the current [_state].
  ///
  /// The internal [_state] may be mutated, thus each feeder is refreshed with
  /// a new [State] by calling [_refreshFeeders].
  void _applyMutations<P>(final MutationToken mutationToken,
      [final P payload]) {
    assert(!_isDisposed);

    _logger.info('Applying mutations');

    if (mutations.isNotEmpty && mutations.containsKey(mutationToken)) {
      for (final Mutation mutation in mutations[mutationToken]) {
        _logger.info('Mutating with mutation $mutation');

        setMutationState(mutation, _state);

        _state = mutation.mutate(payload);
      }

      _refreshFeeders();
    }
  }

  /// Refreshes all feeders.
  ///
  /// Iterates over each [Feeder] registered and refreshes each [Feeder]'s
  /// [State] with the current [_state].
  void _refreshFeeders() {
    assert(!_isDisposed);

    _logger.info('Refreshing feeders with new state');

    if (feeders.isNotEmpty) {
      for (final Feeder feeder in feeders) {
        _logger.info('Setting feeder state for $feeder');

        setFeederState(feeder, _state);
      }
    }
  }
}

/// Applies a store commit to given [store] with given [mutationToken] and an
/// optional [payload].
void applyStoreCommit<P>(final Store store, final MutationToken mutationToken,
    [final P payload]) {
  assert(!store._isDisposed);

  store._applyMutations<P>(mutationToken, payload);
}
