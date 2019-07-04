// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:cage/src/_private.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('class StoreModuleInstantiator', () {
    test('It should create', () {
      expect(StoreModuleInstantiator(MyStore()), isNotNull);
    });

    test('It should throw an AssertionError, when required store is null', () {
      expect(() => StoreModuleInstantiator(null), throwsAssertionError);
    });

    group('constructor', () {
      test('It should add all actions, mutations and feeders to the store', () {
        final MyStore myStore = MyStore();

        final MyFeeder myFeeder = MyFeeder();

        StoreModuleInstantiator<MyState>(myStore, actions: [
          Pairwise<ActionToken, MyAction>(const ActionToken('abc'), MyAction())
        ], mutations: [
          Pairwise<MutationToken, MyMutation>(
              const MutationToken('abc'), MyMutation())
        ], feeders: [
          myFeeder
        ]);

        expect(myStore.actions.containsKey(const ActionToken('abc')), true);
        expect(myStore.mutations.containsKey(const MutationToken('abc')), true);
        expect(myStore.feeders.contains(myFeeder), true);
      });
    });
  });

  group('class Pairwise', () {
    test('It should create', () {
      expect(const Pairwise<String, String>('', ''), isNotNull);
    });
  });
}

class MyState extends State {}

class MyStore extends Store<MyState> {
  MyStore() : super(MyState());
}

class MyAction extends Action<MyState, void> {
  @override
  void execute([final void payload]) {}
}

class MyMutation extends Mutation<MyState, void> {
  @override
  MyState mutate([final void payload]) => null;
}

class MyFeeder extends Feeder<MyState, void> {
  @override
  void getFeed() {}
}
