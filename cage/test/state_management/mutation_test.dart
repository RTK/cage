// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:cage/src/_private.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  MyMutation myMutation;
  MyStore myStore;

  const MutationToken mutationToken = MutationToken('MyToken');

  setUp(() {
    myMutation = MyMutation();
    myStore = MyStore();
  });

  group('setMutationState()', () {
    test('It should set the mutations internal state to given state', () {
      final MyState myState = MyState(1);

      expect(myMutation.state, null);

      setMutationState(myMutation, myState);

      expect(myMutation.state, myState);
    });
  });

  group('setMutationStore()', () {
    test('It should set the mutations internal store to given store', () {
      expect(myMutation.store, null);

      setMutationStore(myMutation, myStore);

      expect(myMutation.store, myStore);
    });

    test(
        'It should throw an AssertionError, when the store is set more than once',
        () {
      setMutationStore(myMutation, myStore);
      expect(() => setMutationStore(myMutation, myStore), throwsAssertionError);
    });

    test(
        'It should not throw, when the store is set more than once but with null',
        () {
      setMutationStore(myMutation, myStore);
      setMutationStore(myMutation, null);

      expect(myMutation.store, null);
    });
  });

  group('setMutationToken()', () {
    test('It should set the mutations internal token to given token', () {
      expect(myMutation.token, null);

      setMutationToken(myMutation, mutationToken);

      expect(myMutation.token, mutationToken);
    });

    test(
        'It should throw an AssertionError, when the token is set more than once',
        () {
      setMutationToken(myMutation, mutationToken);
      expect(() => setMutationToken(myMutation, mutationToken),
          throwsAssertionError);
    });
  });

  group('class Mutation', () {
    test('It should create', () {
      expect(myMutation, isNotNull);
    });

    group('dispose()', () {
      test('It should remove itself from its store', () {
        myStore.addMutation(mutationToken, myMutation);

        expect(myStore.mutations.containsKey(mutationToken), true);

        myMutation.dispose();

        expect(myStore.mutations.containsKey(mutationToken), false);
      });
    });

    group('mutate()', () {
      test('It should return a new mutated state', () {
        final MyState state = MyState(1);
        final MyMutation myMutation = MyMutation();

        setMutationState<MyState>(myMutation, state);

        expect(myMutation.mutate(state).counter, 2);
      });
    });
  });
}

class MyState extends State {
  final int counter;

  const MyState(this.counter);
}

class MyStore extends Store<MyState> {
  MyStore() : super(MyState(0));
}

class MyMutation extends Mutation<MyState, dynamic> {
  @override
  MyState mutate([final dynamic payload]) {
    return MyState(state.counter + 1);
  }
}
