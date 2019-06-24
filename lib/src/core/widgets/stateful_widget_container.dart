// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'view.dart';

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

  final Function onUpdate;

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
  View view;

  StatefulWidgetContainerState(this.view);

  @override
  void initState() {
    super.initState();

    if (widget.onInit != null) {
      widget.onInit();
    }

    widget.onUpdate((final VoidCallback callback) {
      setState(callback);
    });
  }

  @override
  void dispose() {
    if (!mounted && widget.onDispose != null) {
      widget.onDispose();

      view = null;
    }

    super.dispose();
  }

  @override
  Widget build(final BuildContext buildContext) {
    setViewBuildContext(view, buildContext);

    return view.createView();
  }
}
