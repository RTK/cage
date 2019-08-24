// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:cage/src/_private.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Injector injector;
  WidgetContainer<P, V> wc;

  setUp(() {
    injector = emptyInjector.createChild(linkToParent: false);
    wc = WidgetContainer(Key('test'), P(), V(), createPublicInjector(injector));
  });

  group('class WidgetContainer', () {
    test('It should create', () {
      expect(wc, isNotNull);
    });

    group('get widget', () {
      test('It should return the created widget', () {
        expect(wc.widget, isNotNull);
        expect(wc.widget, isInstanceOf<StatefulWidgetContainer>());
      });
    });

    group('createWidget()', () {
      test(
          'It should throw an AssertionError, when the WidgetContainer has been disposed',
          () {
        wc.dispose();
        expect(() => wc.createWidget(Key('da')), throwsAssertionError);
      });
    });

    group('init()', () {
      test('It should call the presenter\'s onInit method', () {
        wc.init();

        expect(wc.presenter.onInitCalled, true);
      });

      test(
          'It should throw an AssertionError, when the WidgetContainer has been disposed',
          () {
        wc.dispose();
        expect(() => wc.init(), throwsAssertionError);
      });
    });

    group('dispose()', () {
      test('It should call the dispose method on the presenter and the view',
          () {
        final P presenter = wc.presenter;
        final V view = wc.view;

        expect(presenter.disposeCalled, false);
        expect(view.disposeCalled, false);

        wc.dispose();

        expect(presenter.disposeCalled, true);
        expect(view.disposeCalled, true);
      });

      test('It should remove the references to the presenter and the view', () {
        wc.dispose();

        expect(wc.presenter, null);
        expect(wc.view, null);
        expect(wc.isAlive, false);
      });

      test(
          'It should throw an AssertionError, when the WidgetContainer has been disposed',
          () {
        wc.dispose();
        expect(() => wc.dispose(), throwsAssertionError);
      });
    });

    group('setOnUpdate()', () {
      final TestsFn testsFn = TestsFn();

      test('It should set the property to given value', () {
        wc.setOnUpdate(testsFn.onUpdate);

        expect(wc.updateWidgetCallback, testsFn.onUpdate);
      });

      test(
          'It should throw an AssertionError, when the update widget callback already has been set',
          () {
        wc.setOnUpdate(testsFn.onUpdate);
        expect(() => wc.setOnUpdate(testsFn.onUpdate), throwsAssertionError);
      });

      test(
          'It should throw an AssertionError, when the WidgetContainer has been disposed',
          () {
        wc.dispose();
        expect(() => wc.setOnUpdate((final VoidCallback callback) {}),
            throwsAssertionError);
      });
    });

    group('updateView()', () {
      test('It should call the updateWidgetCallback with given callback', () {
        final TestsFn testsFn = TestsFn();

        wc.setOnUpdate(testsFn.onUpdate);

        final myCb = () {};

        wc.updateView(myCb);

        expect(testsFn.myCallback, myCb);
      });
      test(
          'It should throw an AssertionError, when the UpdateCallback is not set yet',
          () {
        expect(() => wc.updateView(() {}), throwsAssertionError);
      });

      test(
          'It should throw an AssertionError, when the WidgetContainer has been disposed',
          () {
        wc.dispose();
        expect(() => wc.updateView(() {}), throwsAssertionError);
      });
    });
  });
}

class P extends Presenter {
  bool disposeCalled = false;

  bool onInitCalled = false;

  @override
  void dispose() {
    disposeCalled = true;

    super.dispose();
  }

  @override
  void onInit() {
    onInitCalled = true;
  }
}

class V extends View<P> {
  bool disposeCalled = false;

  @override
  Widget createView() => Container();

  @override
  void dispose() {
    disposeCalled = true;

    super.dispose();
  }
}

class TestsFn {
  VoidCallback myCallback;

  void onUpdate(final VoidCallback callback) {
    myCallback = callback;
  }
}
