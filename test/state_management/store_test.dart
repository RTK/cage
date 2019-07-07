// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:cage/src/_private.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  MyState myState;
  MyStore myStore;

  setUp(() {
    myState = MyState();
    myStore = MyStore(myState);
  });

  group('class Store', () {
    test('It should create', () {
      expect(myStore, isNotNull);
    });

    test('It should throw, when the initial state is null', () {
      expect(() => MyStore(null), throwsAssertionError);
    });

    test(
        'It should listen to the dispatcher if ignoreGlobalDispatcher is false',
        () {
      expect(myStore.dispatcherSubscription, isNotNull);
    });

    group('addAction()', () {
      const ActionToken myToken = const ActionToken('test');
      MyAction myAction;

      setUp(() {
        myAction = MyAction();
      });

      test(
          'It should add given Action to the stores actions with the correct ActionToken',
          () {
        expect(myStore.actions.isEmpty, true);

        myStore.addAction(myToken, myAction);

        expect(myStore.actions.containsKey(myToken), true);
        expect(myStore.actions[myToken] is List, true);
        expect(myStore.actions[myToken].contains(myAction), true);
      });

      test('It should set the Actions store and token correctly', () {
        myStore.addAction(myToken, myAction);

        expect(myAction.store, myStore);
        expect(myAction.token, myToken);
      });

      test(
          'It should throw an AssertionError, when the store is already disposed',
          () {
        myStore.dispose();

        expect(() => myStore.addAction(const ActionToken('123'), null),
            throwsAssertionError);
      });
    });

    group('addFeeder()', () {
      MyFeeder myFeeder;

      setUp(() {
        myFeeder = MyFeeder();
      });

      test('It should add the feeder to the stores feeders list', () {
        myStore.addFeeder(myFeeder);

        expect(myStore.feeders.contains(myFeeder), true);
      });

      test('It should set the Feeders store and state correctly', () {
        myStore.addFeeder(myFeeder);

        expect(myFeeder.store, myStore);
        expect(myFeeder.state, myState);
      });

      test(
          'It should throw an AssertionError, when the store is already disposed',
          () {
        myStore.dispose();

        expect(() => myStore.addFeeder(MyFeeder()), throwsAssertionError);
      });
    });

    group('addMutation()', () {
      const MutationToken myToken = const MutationToken('test');
      MyMutation myMutation;

      setUp(() {
        myMutation = MyMutation();
      });

      test(
          'It should add given Mutation to the stores mutations with the correct MutationToken',
          () {
        expect(myStore.mutations.isEmpty, true);

        myStore.addMutation(myToken, myMutation);

        expect(myStore.mutations.containsKey(myToken), true);
        expect(myStore.mutations[myToken] is List, true);
        expect(myStore.mutations[myToken].contains(myMutation), true);
      });

      test('It should set the Mutations store and token correctly', () {
        myStore.addMutation(myToken, myMutation);

        expect(myMutation.store, myStore);
        expect(myMutation.token, myToken);
      });

      test(
          'It should throw an AssertionError, when the store is already disposed',
          () {
        myStore.dispose();

        expect(() => myStore.addMutation(const MutationToken('123'), null),
            throwsAssertionError);
      });
    });

    group('dispatch()', () {
      test(
          'It should refresh the state of each actions registered for given ActionToken and call its execute method with the correct payload',
          () {
        const ActionToken token = const ActionToken('123');

        final MyAction myAction = MyAction();

        myStore.addAction(token, myAction);

        expect(myAction.state, null);
        expect(myAction.executePayload, null);

        myStore.dispatch(token, 'test');

        expect(myAction.state, myState);
        expect(myAction.executePayload, 'test');
      });

      test('It should be dispatched, when the global Dispatcher emits',
          () async {
        const ActionToken token = const ActionToken('123');

        final MyAction myAction = MyAction();

        myStore.addAction(token, myAction);

        expect(myAction.state, null);
        expect(myAction.executePayload, null);

        myStore.dispatcherSubscription
            .onData((final Envelope<dynamic> envelope) {
          expect(envelope.actionToken, token);
          expect(envelope.payload, 'test');
        });

        Dispatcher().dispatchAction(token, 'test');
      });

      test(
          'It should throw an AssertionError, when the store is already disposed',
          () {
        myStore.dispose();

        expect(() => myStore.dispatch(const ActionToken('123')),
            throwsAssertionError);
      });
    });

    group('dispose()', () {
      test(
          'It should call each registered actions, mutations and feeders dispose method and clear all lists',
          () {
        final MyAction myAction = MyAction();
        final MyMutation myMutation = MyMutation();
        final MyFeeder myFeeder = MyFeeder();

        myStore.addAction(const ActionToken('123'), myAction);
        myStore.addMutation(const MutationToken('123'), myMutation);
        myStore.addFeeder(myFeeder);

        myStore.dispose();

        expect(myAction.disposeCalled, true);
        expect(myMutation.disposeCalled, true);
        expect(myFeeder.disposeCalled, true);

        expect(myStore.actions.length, 0);
        expect(myStore.mutations.length, 0);
        expect(myStore.feeders.length, 0);
      });

      test(
          'It should throw an AssertionError, when the store is already disposed',
          () {
        myStore.dispose();

        expect(() => myStore.dispose(), throwsAssertionError);
      });
    });

    group('removeAction()', () {
      test('It should remove the action from the store', () {
        const ActionToken myToken = const ActionToken('123');

        final MyAction myAction = MyAction();

        expect(myStore.actions.isEmpty, true);

        myStore.addAction(myToken, myAction);
        expect(myStore.actions.isNotEmpty, true);

        myStore.removeAction(myToken, myAction);
        expect(myStore.actions.isEmpty, true);
      });

      test(
          'It should throw an AssertionError, when the store is already disposed',
          () {
        myStore.dispose();

        expect(() => myStore.removeAction(const ActionToken('123'), null),
            throwsAssertionError);
      });
    });

    group('removeFeeder()', () {
      test('It should remove the feeder from the store', () {
        final MyFeeder myFeeder = MyFeeder();

        expect(myStore.feeders.isEmpty, true);

        myStore.addFeeder(myFeeder);
        expect(myStore.feeders.isNotEmpty, true);

        myStore.removeFeeder(myFeeder);
        expect(myStore.feeders.isEmpty, true);
      });

      test(
          'It should throw an AssertionError, when the store is already disposed',
          () {
        myStore.dispose();

        expect(() => myStore.removeFeeder(MyFeeder()), throwsAssertionError);
      });
    });

    group('removeMutation()', () {
      test('It should remove the mutation from the store', () {
        const MutationToken myToken = const MutationToken('123');

        final MyMutation myMutation = MyMutation();

        expect(myStore.mutations.isEmpty, true);

        myStore.addMutation(myToken, myMutation);
        expect(myStore.mutations.isNotEmpty, true);

        myStore.removeMutation(myToken, myMutation);
        expect(myStore.mutations.isEmpty, true);
      });

      test(
          'It should throw an AssertionError, when the store is already disposed',
          () {
        myStore.dispose();

        expect(() => myStore.removeMutation(const MutationToken('123'), null),
            throwsAssertionError);
      });
    });
  });

  group('applyStoreCommit()', () {
    test('It should call all mutations registered for given MutationToken', () {
      const MutationToken token = const MutationToken('123');

      final MyMutation myMutation = MyMutation();

      myStore.addMutation(token, myMutation);

      applyStoreCommit(myStore, token);

      expect(myMutation.mutateCalled, true);
    });

    test(
        'It should throw an AssertionError, when the store is already disposed',
        () {
      myStore.dispose();

      expect(() => applyStoreCommit(myStore, const MutationToken('123')),
          throwsAssertionError);
    });
  });
}

class MyState extends State {}

class MyStore extends Store<MyState> {
  MyStore(final MyState state) : super(state);
}

class MyAction extends Action<MyState, String> {
  bool disposeCalled = false;

  String executePayload;

  @override
  void dispose() {
    disposeCalled = true;

    super.dispose();
  }

  @override
  void execute([final String payload]) {
    executePayload = payload;
  }
}

class MyFeeder extends Feeder<MyState, void> {
  bool disposeCalled = false;

  @override
  void dispose() {
    disposeCalled = true;

    super.dispose();
  }

  @override
  void getFeed() {}
}

class MyMutation extends Mutation<MyState, void> {
  bool disposeCalled = false;

  bool mutateCalled = false;

  @override
  void dispose() {
    disposeCalled = true;

    super.dispose();
  }

  @override
  MyState mutate([final void payload]) {
    mutateCalled = true;

    return MyState();
  }
}
