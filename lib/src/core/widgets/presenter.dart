// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:cage/debug.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'view.dart';

/// A [Presenter] handles the business logic for Widgets.
///
/// A [Presenter] is attached to a [View], while the [View] is attached to
/// the [Presenter], resulting in a bidirectional data-flow.
/// A [Presenter] may implement an interface to expose only certain fields
/// and methods to the [View].
///
/// The [_view] binding is used to trigger [View] updates. Other than that,
/// the [Presenter] shall not manipulate the [_view] instance.
abstract class Presenter<O> {
  final Logger _logger = createLogger('core.widgets.presenter');

  final List<View> _views = [];

  /// Returns if a [View] has been attached to this [Presenter] instance.
  bool get hasView => _views.isNotEmpty;

  O get options => _options;

  set options(final O options) {
    throw Exception('Do not manually set options.');
  }

  bool _isDisposed = false;

  O _options;

  /// The [onInit] method will be called when all dependencies have been
  /// injected and it is safe to work with.
  ///
  /// Since the programmer may not want to use dependencies, the onInit method
  /// is declared with an empty body and may be overwritten.
  @visibleForOverriding
  void onInit() {}

  /// Attaches the [view] to the [Presenter].
  ///
  /// If a view has already been attached, an [Exception] is thrown.
  @mustCallSuper
  void attachView(final View view) {
    assert(_isDisposed != true);
    assert(!_views.contains(view));

    _views.add(view);
  }

  /// Detaches the current view from the [Presenter].
  ///
  /// If no [View] has been attached yet, an [Exception] is thrown.
  @mustCallSuper
  void detachView(final View view) {
    assert(_isDisposed != true);
    assert(_views.contains(view));

    _views.remove(view);
  }

  /// Disposes the [Presenter].
  ///
  /// Detaches the [View], if attached.
  ///
  /// Throws an [Exception] if the [Presenter] already has been disposed.
  @mustCallSuper
  void dispose() {
    assert(_isDisposed != true);

    _logger.info('Disposing');

    _views.clear();

    _isDisposed = true;
  }

  /// Updates the [View]. Each update has to be applied via [callback].
  ///
  /// If no [View] has been attached, an [Exception] is thrown.
  @mustCallSuper
  void updateView(final VoidCallback callback) {
    assert(_isDisposed != true);
    assert(_views.isNotEmpty);

    for (final View view in _views) {
      updateViewFromPresenter(view, callback);
    }
  }
}

void setPresenterOptions<O>(final Presenter<O> presenter, final O options) {
  assert(presenter._isDisposed != true);

  presenter._options = options;
}
