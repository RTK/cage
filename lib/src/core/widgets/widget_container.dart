// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:cage/debug.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'presenter.dart';
import 'stateful_widget_container.dart';
import 'view.dart';

import '../di/public_injector.dart' as Public;

/// A [WidgetContainer] wraps the creation of a [Widget].
/// The resulting [Widget] can be accessed via [widget] get-method.
///
/// The [WidgetContainer] handles the attachment between [Presenter] and
/// [View].
class WidgetContainer<P extends Presenter, V extends View> {
  /// References the [Injector] used to create this [WidgetContainer].
  final Public.Injector injector;

  /// References the [Key], which is used to create instances of this
  /// [WidgetContainer].
  final Key key;

  /// Returns the [_isAlive] boolean.
  get isAlive => _isAlive;

  /// Returns the [_presenter].
  ///
  /// For testing purposes only.
  @visibleForTesting
  P get presenter => _presenter;

  /// Returns the [_view].
  ///
  /// For testing purposes only.
  @visibleForTesting
  V get view => _view;

  /// Returns the [_widget]. Resolves to a [StatefulWidgetContainer] created by
  /// this [WidgetContainer].
  Widget get widget => _widget;

  bool _isAlive = true;

  /// References the [WidgetContainer]'s [Presenter].
  P _presenter;

  /// Returns the [_updateWidgetCallback].
  ///
  /// For testing purposes only.
  Function get updateWidgetCallback => _updateWidgetCallback;

  /// References the [WidgetContainer]'s [View].
  V _view;

  Logger _logger;

  /// Internal storage for the callback used to update the view of the widget.
  ///
  /// Is assigned from the [StatefulWidgetContainer]'s [State].
  Function _updateWidgetCallback;

  /// References the created [StatefulWidgetContainer].
  Widget _widget;

  /// Public constructor for [WidgetContainer].
  ///
  /// Creates the [_widget] instance.
  @mustCallSuper
  WidgetContainer(this.key, this._presenter, this._view, this.injector) {
    _logger = createLogger('core.modules.widgets.widget_container $key');

    setViewUpdateCallback(_view, updateView);
    setViewWidgetCreatorCallback(_view, createWidget);

    _presenter.attachView(_view);
    _view.attachPresenter(_presenter);

    _logger.info('Creating a stateful widget');

    _widget = StatefulWidgetContainer(
      key,
      _view,
      onDispose: dispose,
      onInit: init,
      onUpdate: setOnUpdate,
    );
  }

  /// Creates a [Widget] by using the [WidgetResolver], retrieved by local
  /// [injector].
  @visibleForTesting
  WidgetContainer createWidget(final Key widgetToken,
      [final Object widgetOptions]) {
    assert(_isAlive);

    // TODO: implement

    return null;
  }

  /// Calls the [Presenter] lifecycle hook onInit.
  @visibleForTesting
  void init() {
    assert(_isAlive);

    if (_presenter != null) {
      _logger.info('Triggering onInit hook');

      _presenter.onInit();
    }
  }

  /// Calls the [Presenter] lifecycle hook dispose. Also disposes the [View].
  @visibleForTesting
  void dispose() {
    assert(_isAlive);

    _logger.info('Disposing');

    if (_view != null) {
      _view.dispose();
    }

    if (_presenter != null) {
      _presenter.dispose();
    }

    _view = null;
    _presenter = null;
    _widget = null;

    _isAlive = false;
  }

  /// Sets the [_updateWidgetCallback] to given argument [updateWidgetCallback].
  @visibleForTesting
  void setOnUpdate(final UpdateWidgetCallback updateWidgetCallback) {
    assert(_isAlive);
    assert(_updateWidgetCallback == null);

    _updateWidgetCallback = updateWidgetCallback;
  }

  /// Calls the [_updateWidgetCallback] method with given argument [callback].
  ///
  /// If the [_updateWidgetCallback] equals null, an [Exception] is thrown.
  @visibleForTesting
  void updateView(final VoidCallback callback) {
    assert(_isAlive);
    assert(_updateWidgetCallback != null);

    _updateWidgetCallback(callback);
  }
}
