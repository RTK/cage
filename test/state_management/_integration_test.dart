// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:cage/cage.dart';
import 'package:cage/runtime.dart';
import 'package:flutter_test/flutter_test.dart';

const ActionToken IncrementActionToken = const ActionToken('increment');
const MutationToken IncrementMutationToken = const MutationToken('increment');

const ActionToken ChangeTextActionToken = const ActionToken('change_text');
const MutationToken ChangeTextMutationToken =
    const MutationToken('change_text');

void main() {
  test('It should work', () {
    const ModuleKey storeKey = const ModuleKey('Test');

    final StoreModule<MyState> storeModule =
        StoreModule(storeKey, MyState(0, ''), actions: [
      ActionProvider.fromFactory(
          IncrementActionToken, (final Injector injector) => IncrementAction(),
          dependencies: [MyTestDependency])
    ], mutations: [
      MutationProvider.fromValue(IncrementMutationToken, IncrementMutation())
    ], feeders: [
      IncrementFeeder()
    ]);

    final Module rootModule = Module(const ModuleKey('root'), imports: [
      storeModule
    ], services: [
      ServiceProvider.fromFactory(
          MyTestDependency, (final Injector injector) => MyTestDependency())
    ]);

    final TestCage testCage = FlutterTestRuntime.bootstrapModule(rootModule);

    final Store<MyState> store = testCage.getService(storeKey);

    expect(store, isNotNull);

    store.dispatch(IncrementActionToken);

    final IncrementFeeder incrementFeeder =
        store.getFeeder<IncrementFeeder>()[0];

    incrementFeeder.updates.listen((int counter) {});

    expect(incrementFeeder.getFeed(), 1);
  });
}

class MyTestDependency {}

class MyState extends State {
  final int numberValue;

  final String stringValue;

  const MyState(this.numberValue, this.stringValue);

  @override
  String toString() => '$numberValue | $stringValue';
}

class IncrementAction extends Action<MyState, void> {
  @override
  void execute([final void payload]) {
    if (state.numberValue < 10) {
      commit(IncrementMutationToken);
    }
  }
}

class ChangeTextAction extends Action<MyState, String> {
  @override
  void execute([final String payload]) {
    commit(ChangeTextMutationToken, payload);
  }
}

class IncrementMutation extends Mutation<MyState, Object> {
  @override
  MyState mutate([final Object payload]) {
    final MyState newState = MyState(state.numberValue + 1, state.stringValue);

    return newState;
  }
}

class ChangeTextMutation extends Mutation<MyState, String> {
  @override
  MyState mutate([final String payload]) {
    return MyState(state.numberValue, payload);
  }
}

class IncrementFeeder extends Feeder<MyState, int> {
  @override
  int getFeed() => state.numberValue;
}

class ChangeTextFeeder extends Feeder<MyState, String> {
  @override
  String getFeed() => state.stringValue.split('').reversed.toList().join('');
}
