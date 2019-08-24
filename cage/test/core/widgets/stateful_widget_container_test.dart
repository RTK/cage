// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:cage/src/_private.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  MyView myView;
  StatefulWidgetContainer widget;

  final UpdateCallback updateCallback =
      (final UpdateWidgetCallback updateWidgetCallback) {};

  setUp(() {
    myView = MyView();

    widget = StatefulWidgetContainer(Key('stateful_test'), myView,
        onUpdate: updateCallback);
  });

  tearDown(() {
    myView = null;
    widget = null;
  });

  group('StatefulWidgetContainer', () {
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

  group('StatefulWidgetContainerState', () {
    StatefulWidgetContainerState state;

    setUp(() {
      state = StatefulWidgetContainerState(myView);
    });

    test('It should create', () {
      expect(state, isNotNull);
    });

    group('initState()', () {
      test('It should set the updateView method', () {
        expect(state.updateView, isNull);
        expect(state.widgetRef, isNull);

        expect(() => state.initState(), throwsAssertionError);

        expect(state.updateView, isInstanceOf<Function>());
      });
    });

    group('onInit()', () {
      test('It should call the onInit method of its widget, when defined', () {
        bool wasCalled = false;

        final VoidCallback onInit = () {
          wasCalled = true;
        };

        final UpdateCallback onUpdate =
            (final UpdateWidgetCallback updateWidgetCallback) {};

        state.widgetRef = StatefulWidgetContainer(Key('test'), myView,
            onUpdate: onUpdate, onInit: onInit);

        state.onInit();

        expect(wasCalled, true);
      });

      test(
          'It should call the onUpdate method of its widget with an Function as argument',
          () {
        bool wasCalled = false;
        UpdateWidgetCallback updateCb;

        final VoidCallback onInit = () {};

        final UpdateCallback onUpdate =
            (final UpdateWidgetCallback updateWidgetCallback) {
          wasCalled = true;
          updateCb = updateWidgetCallback;
        };

        state.widgetRef = StatefulWidgetContainer(Key('test'), myView,
            onUpdate: onUpdate, onInit: onInit);

        state.onInit();

        expect(wasCalled, true);
        expect(updateCb is Function, true);
      });

      test(
          'It should call the updateView function, when the update function is called',
          () {
        bool wasCalled = false;

        final UpdateCallback onUpdate =
            (final UpdateWidgetCallback updateWidgetCallback) {
          updateWidgetCallback(() {});
        };

        state.widgetRef =
            StatefulWidgetContainer(Key('test'), myView, onUpdate: onUpdate);

        state.updateView = (final VoidCallback cb) {
          wasCalled = true;
        };

        state.onInit();

        expect(wasCalled, true);
      });
    });

    group('onDispose()', () {
      test('It should call the onDispose method of its widget when defined',
          () {
        bool wasCalled = false;

        final VoidCallback onDispose = () {
          wasCalled = true;
        };

        final UpdateCallback onUpdate =
            (final UpdateWidgetCallback updateWidgetCallback) {};

        state.widgetRef = StatefulWidgetContainer(Key('test'), myView,
            onUpdate: onUpdate, onDispose: onDispose);

        state.onDispose();

        expect(wasCalled, true);
        expect(state.view, isNull);
      });
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
