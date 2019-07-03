// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter/widgets.dart' as prefix0;
import 'package:meta/meta.dart';

import 'types.dart';
import 'view.dart';

typedef _UpdateViewCallback = void Function(VoidCallback);

typedef UpdateCallback = void Function(UpdateWidgetCallback);

/// Wraps a [StatefulWidget].
///
/// A [StatefulWidget] represents a [Widget], which data may change over time,
/// thus creating a [State].
///
/// The [StatefulWidget] is marked as [immutable], since the [State] data may
/// change.
@immutable
class StatefulWidgetContainer extends StatefulWidget {
  final VoidCallback onInit;

  final VoidCallback onDispose;

  final UpdateCallback onUpdate;

  final View view;

  StatefulWidgetContainer(final Key key, this.view,
      {this.onDispose, this.onInit, @required this.onUpdate})
      : assert(view != null),
        assert(onUpdate != null),
        super(key: key);

  @override
  StatefulWidgetContainerState createState() =>
      StatefulWidgetContainerState(view);
}

class StatefulWidgetContainerState extends State<StatefulWidgetContainer> {
  @visibleForTesting
  _UpdateViewCallback updateView;

  @visibleForTesting
  View view;

  @visibleForTesting
  StatefulWidgetContainer widgetRef;

  StatefulWidgetContainerState(this.view);

  @override
  void initState() {
    super.initState();

    updateView = setState;
    widgetRef = widget;

    onInit();
  }

  @override
  void dispose() {
    onDispose();

    super.dispose();
  }

  @visibleForTesting
  void onDispose() {
    assert(widgetRef != null);

    if (!mounted && widgetRef.onDispose != null) {
      widgetRef.onDispose();

      view = null;
    }
  }

  @visibleForTesting
  void onInit() {
    assert(widgetRef != null);

    if (widgetRef.onInit != null) {
      widgetRef.onInit();
    }

    widgetRef.onUpdate((final VoidCallback callback) {
      updateView(callback);
    });
  }

  @override
  Widget build(final BuildContext buildContext) {
    setViewBuildContext(view, buildContext);

    return view.createView();
  }
}
