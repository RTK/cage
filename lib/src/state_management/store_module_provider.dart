// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:cage/cage.dart' as Public;
import 'package:cage/src/_private.dart';

import 'action.dart';
import 'feeder.dart';
import 'mutation.dart';
import 'transaction_tokens.dart';

typedef ActionFactoryProvider = Action Function(Public.Injector injector);

typedef FeederFactoryProvider = Feeder Function(Public.Injector injector);

typedef MutationFactoryProvider = Mutation Function(Public.Injector injector);

/// ServiceProvider to provide an [Action] as service.
///
/// Takes an [ActionToken] and an instance of [Action.
class ActionProvider extends _ServiceProvider<ActionToken, Action> {
  ActionProvider.fromFactory(
      final ActionToken provideAs, final ActionFactoryProvider factoryProvider,
      {final List<Object> dependencies})
      : super.fromFactory(provideAs, factoryProvider,
            dependencies: dependencies);

  ActionProvider.fromValue(final ActionToken provideAs, final Action action)
      : super.fromValue(provideAs, action);
}

/// ServiceProvider to provide a [Feeder] as service.
///
/// Can only be instantiated from value.
///
/// Is provided locally.
class FeederProvider extends ServiceProvider<Feeder> {
  FeederProvider.fromValue(final Feeder feeder)
      : super.fromValue(feeder,
            provideAs: feeder, location: ServiceProviderLocation.Local);
}

/// ServiceProvider to provide a [Mutation] as service.
///
/// Takes a [MutationToken] and an instance of [Mutation].
class MutationProvider extends _ServiceProvider<MutationToken, Mutation> {
  MutationProvider.fromFactory(final MutationToken provideAs,
      final MutationFactoryProvider mutationProvider,
      {final List<Object> dependencies})
      : super.fromFactory(provideAs, mutationProvider,
            dependencies: dependencies);

  MutationProvider.fromValue(
      final MutationToken provideAs, final Mutation mutation)
      : super.fromValue(provideAs, mutation);
}

/// Base class for [ActionProvider] and [MutationProvider]
///
/// Extends [ServiceProvider].
///
/// Is used to default the ServiceProviderLocation and the
/// [ServiceProviderInstantiationType].
class _ServiceProvider<T, I> extends ServiceProvider<I> {
  _ServiceProvider.fromFactory(
      final T provideAs, final FactoryProvider factoryProvider,
      {final List<Object> dependencies})
      : super.fromFactory(provideAs, factoryProvider,
            instantiationType: ServiceProviderInstantiationType.OnInject,
            location: ServiceProviderLocation.Local,
            dependencies: dependencies);

  _ServiceProvider.fromValue(final T provideAs, final I value)
      : super.fromValue(value,
            provideAs: provideAs, location: ServiceProviderLocation.Local);
}
