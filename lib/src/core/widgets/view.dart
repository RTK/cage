// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:cage/debug.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'types.dart';
import 'widget_container.dart';
import 'widget_container_factory.dart';

typedef WidgetCreatorCallback<O> = WidgetContainer Function(Key widgetToken,
    [O widgetOptions]);

/// A [View] handles the building of the [Widget] inserted into the flutter
/// WidgetTree.
///
/// A [View] references a [Presenter], which will be used for business logic,
/// such as receiving data, calling actions, etc. The [Presenter] type is
/// dynamically typed [P].
abstract class View<P> {
  final Logger _logger = createLogger('core.widgets.view');

  /// Caches widgets called via [spawnWidget].
  final Map<String, WidgetContainer> _widgetCache = Map();

  /// Returns the [_buildContext].
  BuildContext get buildContext => _buildContext;

  /// Returns if a [Presenter] has been attached to this [View].
  bool get hasPresenter => presenter != null;

  /// References the presenter's instance.
  P get presenter => _presenter;

  /// Returns the [_updateCallback].
  ///
  /// For testing purposes only.
  @visibleForTesting
  UpdateWidgetCallback get updateCallback => _updateCallback;

  /// Returns the [_widgetCreatorCallback].
  ///
  /// For testing purposes only.
  @visibleForTesting
  WidgetCreatorCallback get widgetCreatorCallback => _widgetCreatorCallback;

  BuildContext _buildContext;

  bool _isDisposed = false;

  P _presenter;

  UpdateWidgetCallback _updateCallback;

  WidgetCreatorCallback _widgetCreatorCallback;

  /// Attaches a [Presenter] to this [View].
  @mustCallSuper
  void attachPresenter(final P presenter) {
    assert(_presenter == null);
    assert(!_isDisposed);

    _presenter = presenter;
  }

  /// Callback triggered by the [Widget] build method.
  ///
  /// Receives a [BuildContext] as argument.
  @factory
  @visibleForOverriding
  Widget createView();

  /// Detaches the [Presenter] from the [View] instance.
  ///
  /// If there is no [Presenter] attached, an [Exception] is thrown.
  @mustCallSuper
  void detachPresenter() {
    assert(_presenter != null);
    assert(!_isDisposed);

    _presenter = null;
  }

  /// Called when the [Presenter] is disposed (WidgetContainer is removed from
  /// tree).
  ///
  /// Detaches the [Presenter], if attached.
  ///
  /// Throws an [AssertionError], if the dispose method already has been called,
  /// signaling errors in the architecture.
  @mustCallSuper
  void dispose() {
    assert(!_isDisposed);

    _logger.info('Disposing');

    _presenter = null;
    _updateCallback = null;
    _widgetCreatorCallback = null;

    _isDisposed = true;
  }

  /// Method used to create child [Widget]s.
  ///
  /// Accepts a [widgetToken] and optionally [widgetOptions] as argument. Tries
  /// to resolve a WidgetContainer for given widgetToken. If successfully, a
  /// WidgetContainer will be invoked with given [widgetOptions].
  ///
  /// An [AssertionError] is thrown, when the WidgetContainer for this [View]
  /// has not yet attached the [_widgetCreatorCallback], used to resolve
  /// [WidgetContainer].
  @mustCallSuper
  Widget spawnWidget(final WidgetContainerFactory widgetContainerFactory,
      {final Object widgetOptions, final bool forceCreation = false}) {
    assert(!_isDisposed);
    assert(_widgetCreatorCallback != null);
    assert(widgetContainerFactory != null);

    final String id = _generateWidgetFingerprint(
        widgetContainerFactory.widgetKey, widgetOptions);

    if (_widgetCache.containsKey(id) &&
        _widgetCache[id] != null &&
        _widgetCache[id].isAlive &&
        !forceCreation) {
      _logger.info('Resolve from cache with id $id');

      return _widgetCache[id].widget;
    }

    _logger
        .info('Creating widget anew. -> ${widgetContainerFactory.widgetKey}');

    final WidgetContainer widgetContainer =
        _widgetCreatorCallback(widgetContainerFactory.widgetKey, widgetOptions);

    _widgetCache[id] = widgetContainer;

    return widgetContainer.widget;
  }

  /// Generates a fingerprint for widgets consisting of the [token] and the
  /// [options].
  ///
  /// Is used for local factory caching.
  String _generateWidgetFingerprint(final Key token, final Object options) {
    String fingerprint = 'FP_${token.hashCode}';

    if (options != null) {
      fingerprint += '-${options.hashCode}';
    }

    return fingerprint;
  }
}

/// Sets the [view]'s buildContext to [buildContext].
void setViewBuildContext(final View view, final BuildContext buildContext) {
  assert(!view._isDisposed);

  view._buildContext = buildContext;
}

/// Sets the [view]'s updateCallback to [updateCb].
void setViewUpdateCallback(
    final View view, final UpdateWidgetCallback updateCb) {
  assert(!view._isDisposed);
  assert(view._updateCallback == null);

  view._updateCallback = updateCb;
}

/// Sets the [view]'s [WidgetCreatorCallback] to [widgetCreatorCallback].
void setViewWidgetCreatorCallback(
    final View view, final WidgetCreatorCallback widgetCreatorCallback) {
  assert(!view._isDisposed);
  assert(view._widgetCreatorCallback == null);

  view._widgetCreatorCallback = widgetCreatorCallback;
}

/// Calls the [view]'s updateCallback with [updateCb].
void updateViewFromPresenter<P>(
    final View<P> view, final VoidCallback updateCb) {
  assert(!view._isDisposed);

  view._updateCallback(updateCb);
}
