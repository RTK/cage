// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'presenter.dart';
import 'view.dart';
import 'widget_container.dart';

import '../di/public_injector.dart' as Public;

typedef PresenterCreationCallback = Presenter Function(
    Public.Injector injector);

typedef ViewCreationCallback = View Function();

/// Creates a [WidgetContainer], which wraps the creation of a [Widget].
///
/// The [Widget] type is a [StatefulWidget] by default. By passing the
/// [widgetType], the type can be changed to be a [StatelessWidget].
class WidgetContainerFactory<O> {
  final PresenterCreationCallback createPresenter;

  final ViewCreationCallback createView;

  final Key widgetKey;

  @mustCallSuper
  WidgetContainerFactory(
      {@required this.createPresenter,
      @required this.createView,
      @required this.widgetKey})
      : assert(createPresenter != null),
        assert(createView != null),
        assert(widgetKey != null);

  /// Creates the [WidgetContainer] instance.
  ///
  /// The instance will receive the [key]. Furthermore the [injector] is used
  /// to resolve [Presenter] dependencies.
  WidgetContainer _createWidgetContainer(
      final Public.Injector injector, final O widgetOptions) {
    final Presenter presenter = createPresenter(injector);

    if (widgetOptions != null) {
      setPresenterOptions(presenter, widgetOptions);
    }

    return WidgetContainer(widgetKey, presenter, createView(), injector);
  }
}

WidgetContainer createWidgetContainer<O>(final WidgetContainerFactory factory,
        final Public.Injector injector, final O widgetOptions) =>
    factory._createWidgetContainer(injector, widgetOptions);
