// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:cage/src/_private.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  MyView myView;
  StatefulWidgetContainer widget;

  var updateCallback = (final UpdateWidgetCallback updateWidgetCallback) {};

  setUp(() {
    myView = MyView();

    widget = StatefulWidgetContainer(Key('stateful_test'), myView,
        onUpdate: updateCallback);
  });

  tearDown(() {
    myView = null;
    widget = null;
  });

  group('class StatefulWidgetContainer', () {
    test('It should create', () {
      expect(widget, isNotNull);
    });

    test('It should throw an AssertionError, when no view is given', () {
      expect(() => StatefulWidgetContainer(Key('test'), null, onUpdate: null),
          throwsAssertionError);
    });

    test(
        'It should throw an AssertionError, when no updateViewCallback is given',
        () {
      expect(() => StatefulWidgetContainer(Key('test'), myView, onUpdate: null),
          throwsAssertionError);
    });

    group('createState', () {
      test('It should return a StatefulWidgetContainerState', () {
        expect(
            widget.createState(), isInstanceOf<StatefulWidgetContainerState>());
      });
    });
  });

  group('class StatefulWidgetContainerState', () {
    test('It should create', () {
      expect(StatefulWidgetContainerState(myView), isNotNull);
    });
  });
}

class MyView extends View {
  var creationCallback = () => Container();

  @override
  Widget createView() => creationCallback();
}

// ignore: must_be_immutable
class MyStatefulWidgetContainer extends StatefulWidgetContainer {
  StatefulWidgetContainerState state;

  MyStatefulWidgetContainer(final Key key, final View view,
      final dynamic onUpdate, final VoidCallback onDispose)
      : super(key, view, onUpdate: onUpdate, onDispose: onDispose);

  @override
  StatefulWidgetContainerState createState() {
    state = super.createState();

    return state;
  }
}
