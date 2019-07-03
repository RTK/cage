// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:cage/src/_private.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  MyAction myAction;
  MyStore myStore;

  const ActionToken myToken = ActionToken('test');

  setUp(() {
    myAction = MyAction();
    myStore = MyStore();
  });

  group('setActionState()', () {
    test('It should set the actions state to given state', () {
      expect(myAction.state, null);

      final MyState myState = MyState();

      setActionState(myAction, myState);

      expect(myAction.state, myState);
    });
  });

  group('setActionStore()', () {
    test('It should set the actions store to given store', () {
      expect(myAction.store, null);

      setActionStore(myAction, myStore);

      expect(myAction.store, myStore);
    });

    test(
        'It should throw an AssertionError, when the store is set more than once',
        () {
      setActionStore(myAction, myStore);
      expect(() => setActionStore(myAction, myStore), throwsAssertionError);
    });

    test(
        'It should not throw, when the store is set more than once but with null',
        () {
      setActionStore(myAction, myStore);
      setActionStore(myAction, null);

      expect(myAction.store, null);
    });
  });

  group('setActionToken()', () {
    test('It should set the actions token to given token', () {
      expect(myAction.token, null);

      setActionToken(myAction, myToken);

      expect(myAction.token, myToken);
    });

    test(
        'It should throw an AssertionError, when the token is set more than once',
        () {
      setActionToken(myAction, myToken);
      expect(() => setActionToken(myAction, myToken), throwsAssertionError);
    });
  });

  group('class Action', () {
    test('It should create', () {
      expect(myAction, isNotNull);
    });

    group('applyCommit', () {
      test('It should be the applyStoreCommit method', () {
        expect(myAction.applyCommit, applyStoreCommit);
      });
    });

    group('commit', () {
      test('It should commit the changes to the store', () {
        myAction.applyCommit =
            (final MyStore store, final MutationToken mutationToken,
                [final dynamic payload]) {
          myStore.payload = payload;
        };

        setActionStore(myAction, myStore);

        myAction.execute('123');

        expect(myStore.payload, isNotNull);
        expect(myStore.payload, '123');
      });
    });

    group('dispose()', () {
      test('It should remove itself from its store', () {
        myStore.addAction(myToken, myAction);

        expect(myStore.actions.containsKey(myToken), true);

        myAction.dispose();

        expect(myStore.actions.containsKey(myToken), false);
      });
    });
  });
}

class MyAction extends Action<MyState, dynamic> {
  @override
  void execute([final dynamic payload]) {
    commit(const MutationToken('test'), payload);
  }
}

class MyState extends State {}

class MyStore extends Store<MyState> {
  dynamic payload;

  MyStore() : super(MyState());
}
