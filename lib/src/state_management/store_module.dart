// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:cage/cage.dart' as Public show Injector;
import 'package:cage/src/_private.dart';
import 'package:meta/meta.dart';

import 'action.dart';
import 'feeder.dart';
import 'mutation.dart';
import 'state.dart';
import 'private_store.dart';
import 'public_store.dart' as Public;
import 'store_module_instantiator.dart';
import 'store_module_provider.dart';
import 'transaction_tokens.dart';

/// Wraps a [Store] to provide as a [ModuleType] to be used as a [Module] type
/// pattern.
///
/// Can be imported from [Module]s.
///
/// Takes [Action]s, [Feeder]s and [Mutation]s.
class StoreModule<S extends State> extends ModuleType {
  /// References all [Action]s associated with the [_store].
  final List<ActionProvider> actions;

  /// References all [Feeder]s associated with the [_store].
  final List<Object> feeders;

  /// References all [Mutation]s associated with the [_store].
  final List<MutationProvider> mutations;

  final Logger _logger = createLogger('StoreModule');

  /// References the original [_store].
  final Store<S> _store;

  /// Returns the internal module to be used by the module system.
  @override
  Module get module => _module;

  /// References the internal [Module].
  Module _module;

  /// Public constructor for [StoreModule].
  ///
  /// Takes an [id] and an [initialState].
  ///
  /// Optionally takes [actions], [feeders] and [mutations].
  ///
  /// If the [id] is null, an [AssertionError] is thrown.
  ///
  /// Initialises the internal [_store] and calls the super [ModuleType] class
  /// with the [id].
  StoreModule(final ModuleKey id, final S initialState,
      {this.actions, this.feeders, this.mutations})
      : _store = Store<S>(initialState),
        super(id) {
    final List<ServiceProvider> moduleServices = [];

    final List<_TokenPairwise<ActionToken>> actionTokens = [];
    final List<_TokenPairwise> feederTokens = [];
    final List<_TokenPairwise<MutationToken>> mutationTokens = [];

    _initActions(moduleServices, actionTokens);
    _initFeeders(moduleServices, feederTokens);
    _initMutations(moduleServices, mutationTokens);

    _init(moduleServices, actionTokens, mutationTokens, feederTokens);

    final Public.Store<S> pubStore = Public.createStoreModuleAccessor(_store);

    moduleServices.add(ServiceProvider.fromValue(pubStore,
        provideAs: id, location: ServiceProviderLocation.Parent));

    final Module storeModule = Module(id, services: moduleServices);

    _module = storeModule;
  }

  /// Dispose method, triggered when the module is no longer needed. Disposes
  /// the internal [_store].
  void dispose() {
    _store.dispose();
  }

  /// Initializes the [_store] with all [Action]s, [Mutation]s and [Feeder]s.
  ///
  /// For doing so a central service ([StoreModuleInstantiator]) is added as
  /// module service defining each [Action], [Mutation] and [Feeder] as
  /// dependency.
  ///
  /// The central service will retrieve each [Action], [Mutation] and [Feeder]
  /// through the [Injector] and add each to the [_store].
  ///
  /// The service is instantiated on boot and will be provided locally.
  void _init(
      final List<ServiceProvider> moduleServices,
      final List<_TokenPairwise<ActionToken>> actionTokens,
      final List<_TokenPairwise<MutationToken>> mutationTokens,
      final List<_TokenPairwise> feederTokens) {
    final List<InjectionToken> dependencies = [];

    dependencies.addAll(actionTokens
        .map((final _TokenPairwise<ActionToken> tp) => tp.injectionToken)
        .toList(growable: false));
    dependencies.addAll(mutationTokens
        .map((final _TokenPairwise<MutationToken> tp) => tp.injectionToken)
        .toList(growable: false));
    dependencies.addAll(feederTokens
        .map((final _TokenPairwise tp) => tp.injectionToken)
        .toList(growable: false));

    _logger.info('Initialize with dependencies $dependencies');

    moduleServices.add(ServiceProvider.fromFactory('_store_module_instantiator',
        (final Public.Injector injector) {
      _logger.info('Instantiate store module');

      final List<Pairwise<ActionToken, Action>> storeActions = [];
      final List<Feeder> storeFeeders = [];
      final List<Pairwise<MutationToken, Mutation>> storeMutations = [];

      for (final _TokenPairwise<ActionToken> tokens in actionTokens) {
        final Action action = injector.getDependency(tokens.injectionToken);

        _logger.info('Initializing store with action "$action".');

        storeActions.add(Pairwise(tokens.token, action));
      }

      for (final _TokenPairwise<MutationToken> tokens in mutationTokens) {
        final Mutation mutation = injector.getDependency(tokens.injectionToken);

        _logger.info('Initializing store with mutation "$mutation".');

        storeMutations.add(Pairwise(tokens.token, mutation));
      }

      for (final _TokenPairwise tokens in feederTokens) {
        final Feeder feeder = injector.getDependency(tokens.injectionToken);

        _logger.info('Initializing store with feeder "$feeder".');

        storeFeeders.add(feeder);
      }

      return StoreModuleInstantiator(_store,
          feeders: storeFeeders,
          actions: storeActions,
          mutations: storeMutations);
    },
        dependencies: dependencies,
        instantiationType: ServiceProviderInstantiationType.OnBoot,
        location: ServiceProviderLocation.Local));
  }

  /// Initializes all [Action]s.
  ///
  /// Adds each [ActionServiceProvider] to the global services list and adds a
  /// [_TokenPairwise] containing the [InjectionToken] and the [ActionToken]
  /// to the [actionTokens] list to be used to instantiate the [_store].
  void _initActions(final List<ServiceProvider> moduleServices,
      final List<_TokenPairwise<ActionToken>> actionTokens) {
    _logger.info('Initialize actions');

    if (actions != null && actions.isNotEmpty) {
      for (final ActionProvider actionServiceProvider in actions) {
        moduleServices.add(actionServiceProvider);

        actionTokens.add(_TokenPairwise(actionServiceProvider.injectionToken,
            getServiceProviderOriginalToken(actionServiceProvider)));

        _logger.info(
            'Added action with token "${actionServiceProvider.injectionToken}"');
      }
    }
  }

  /// Initializes all [Feeders]s.
  ///
  /// Adds each [FeederServiceProvider] to the global services list and adds a
  /// [_TokenPairwise] containing the [InjectionToken]
  /// to the [feederTokens] list to be used to instantiate the [_store].
  void _initFeeders(final List<ServiceProvider> moduleServices,
      final List<_TokenPairwise> feederTokens) {
    _logger.info('Initialize feeders');

    if (feeders != null && feeders.isNotEmpty) {
      for (final Object feeder in feeders) {
        assert(feeder is Feeder || feeder is FeederProvider);

        if (feeder is Feeder) {
          final FeederProvider feederServiceProvider =
              FeederProvider.fromValue(feeder);

          moduleServices.add(feederServiceProvider);

          feederTokens
              .add(_TokenPairwise(feederServiceProvider.injectionToken, null));

          _logger.info(
              'Added feeder with token "${feederServiceProvider.injectionToken}"');
        } else if (feeder is FeederProvider) {
          moduleServices.add(feeder);

          feederTokens.add(_TokenPairwise(feeder.injectionToken, null));

          _logger.info(
              'Added feeder from provider with token "${feeder.injectionToken}"');
        }
      }
    }
  }

  /// Initializes all [Mutation]s.
  ///
  /// Adds each [MutationServiceProvider] to the global services list and adds a
  /// [_TokenPairwise] containing the [InjectionToken] and the [MutationToken]
  /// to the [mutationTokens] list to be used to instantiate the [_store].
  void _initMutations(final List<ServiceProvider> moduleServices,
      final List<_TokenPairwise<MutationToken>> mutationTokens) {
    _logger.info('Initialize mutations');

    if (mutations != null && mutations.isNotEmpty) {
      for (final MutationProvider mutationServiceProvider in mutations) {
        moduleServices.add(mutationServiceProvider);

        mutationTokens.add(_TokenPairwise(
            mutationServiceProvider.injectionToken,
            getServiceProviderOriginalToken(mutationServiceProvider)));

        _logger.info(
            'Added mutation with token "${mutationServiceProvider.injectionToken}"');
      }
    }
  }
}

/// Private class used to store [InjectionToken] and a generic type token.
///
/// Is marked immutable.
@immutable
class _TokenPairwise<T> {
  final InjectionToken injectionToken;

  final T token;

  @literal
  const _TokenPairwise(this.injectionToken, this.token);
}

/// Returns the [Store] from given [storeModule].
Store<S> getStoreModuleStore<S extends State>(
        final StoreModule<S> storeModule) =>
    storeModule._store;
