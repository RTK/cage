// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:cage/cage.dart' hide Store;
import 'package:cage/runtime.dart';
import 'package:cage/src/_private.dart' show Store, getStoreModuleStore;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('class StoreModule', () {
    test('It should create', () {
      final StoreModule storeModule =
          StoreModule(const ModuleKey('MyStore'), MyState());

      expect(storeModule, isNotNull);

      storeModule.dispose();
    });

    test('It should throw an AssertionError, when null is given for id', () {
      expect(() => StoreModule(null, MyState()), throwsAssertionError);
    });

    test(
        'It should throw an AssertionError, when null is given for initial state',
        () {
      expect(() => StoreModule(const ModuleKey('MyStore'), null),
          throwsAssertionError);
    });

    test('It should create an internal module', () {
      final StoreModule storeModule =
          StoreModule(const ModuleKey('MyStore'), MyState());

      expect(storeModule.module, isNotNull);
      expect(storeModule.module, isInstanceOf<Module>());

      storeModule.dispose();
    });

    group('Add actions', () {
      test('It should add the action to the store', () {
        final StoreModule storeModule =
            StoreModule(const ModuleKey('MyStore'), MyState(), actions: [
          ActionProvider.fromFactory(const ActionToken('MyTest'),
              (final Injector injector) => MyTestAction())
        ]);

        expect(storeModule, isNotNull);

        FlutterTestRuntime.bootstrapModule(storeModule);

        final Store store = getStoreModuleStore(storeModule);

        expect(store.actions.containsKey(const ActionToken('MyTest')), true);
      });
    });

    group('Add mutations', () {
      test('It should add the mutation to the store', () {
        final StoreModule<MyState> storeModule =
            StoreModule(const ModuleKey('MyStore'), MyState(), mutations: [
          MutationProvider.fromFactory(const MutationToken('MyTest'),
              (final Injector injector) => MyTestMutation())
        ]);

        expect(storeModule, isNotNull);

        FlutterTestRuntime.bootstrapModule(storeModule);

        final Store store = getStoreModuleStore(storeModule);

        expect(
            store.mutations.containsKey(const MutationToken('MyTest')), true);
      });
    });

    group('Add feeders', () {
      test('It should add the feeders to the store', () {
        final StoreModule<MyState> storeModule = StoreModule(
            const ModuleKey('MyStore'), MyState(), feeders: [
          MyTestFeeder(),
          FeederProvider.fromValue(MyTestFeeder2())
        ]);

        expect(storeModule, isNotNull);

        FlutterTestRuntime.bootstrapModule(storeModule);

        final Store store = getStoreModuleStore(storeModule);

        expect(store.feeders.length, 2);
        expect(store.feeders[0], isInstanceOf<MyTestFeeder>());
        expect(store.feeders[1], isInstanceOf<MyTestFeeder2>());
      });
    });
  });
}

class MyState extends State {}

class MyTestAction extends Action {
  @override
  void execute([final void payload]) {}
}

class MyTestMutation extends Mutation {
  @override
  State mutate([final payload]) {
    return null;
  }
}

class MyTestFeeder extends Feeder {
  @override
  getFeed() => null;
}

class MyTestFeeder2 extends Feeder {
  @override
  getFeed() => null;
}
