// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:cage/cage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('class ActionProvider', () {
    group('constructor fromFactory()', () {
      test('It should create', () {
        expect(
            ActionProvider.fromFactory(const ActionToken('test'),
                (final Injector injector) => MyAction()),
            isNotNull);
      });

      test('It should have the correct instantiationType and location', () {
        final ActionProvider provider = ActionProvider.fromFactory(
            const ActionToken('test'), (final Injector injector) => MyAction());

        expect(provider.location, ServiceProviderLocation.Local);
        expect(provider.instantiationType,
            ServiceProviderInstantiationType.OnInject);
      });
    });

    group('constructor fromValue()', () {
      test('It should create', () {
        expect(ActionProvider.fromValue(const ActionToken('test'), MyAction()),
            isNotNull);
      });

      test('The location should be correct', () {
        final ActionProvider provider =
            ActionProvider.fromValue(const ActionToken('test'), MyAction());

        expect(provider.location, ServiceProviderLocation.Local);
      });
    });
  });

  group('class FeederProvider', () {
    group('constructor fromValue', () {
      test('It should create', () {
        expect(FeederProvider.fromValue(MyFeeder()), isNotNull);
      });

      test('It should have the correct location', () {
        final FeederProvider provider = FeederProvider.fromValue(MyFeeder());

        expect(provider.location, ServiceProviderLocation.Local);
      });
    });
  });

  group('class MutationProvider', () {
    group('constructor fromFactory()', () {
      test('It should create', () {
        expect(
            MutationProvider.fromFactory(const MutationToken('test'),
                (final Injector injector) => MyMutation()),
            isNotNull);
      });

      test('It should have the correct instantiationType and location', () {
        final MutationProvider provider = MutationProvider.fromFactory(
            const MutationToken('test'),
            (final Injector injector) => MyMutation());

        expect(provider.location, ServiceProviderLocation.Local);
        expect(provider.instantiationType,
            ServiceProviderInstantiationType.OnInject);
      });
    });

    group('constructor fromValue()', () {
      test('It should create', () {
        expect(
            MutationProvider.fromValue(
                const MutationToken('test'), MyMutation()),
            isNotNull);
      });

      test('It should have the correct location', () {
        final MutationProvider provider = MutationProvider.fromValue(
            const MutationToken('test'), MyMutation());

        expect(provider.location, ServiceProviderLocation.Local);
      });
    });
  });
}

class MyAction extends Action {
  @override
  void execute([payload]) {}
}

class MyMutation extends Mutation {
  @override
  State mutate([payload]) => null;
}

class MyFeeder extends Feeder {
  @override
  void getFeed() => null;
}
