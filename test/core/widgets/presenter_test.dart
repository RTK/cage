// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:cage/src/_private.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  MyPresenter myPresenter;

  setUp(() {
    myPresenter = MyPresenter();
  });

  group('class Presenter', () {
    group('set options()', () {
      test('It should throw an Exception', () {
        expect(() => myPresenter.options = '123', throwsException);
      });
    });

    group('attachView()', () {
      test('It should attach given view', () {
        final MyView myView = MyView();

        myPresenter.attachView(myView);

        expect(myPresenter.hasView, true);
      });

      test(
          'It should throw an AssertionError, when given view is already attached',
          () {
        final MyView myView = MyView();

        myPresenter.attachView(myView);
        expect(() => myPresenter.attachView(myView), throwsAssertionError);
      });

      test(
          'It should throw an AssertionError, when the presenter has been disposed',
          () {
        myPresenter.dispose();

        expect(() => myPresenter.attachView(null), throwsAssertionError);
      });
    });

    group('detachView()', () {
      test('It should remove the view from the presenter', () {
        final MyPresenter myPresenter = MyPresenter();
        final MyView myView = MyView();

        myPresenter.attachView(myView);
        myPresenter.detachView(myView);

        expect(myPresenter.hasView, false);
      });

      test('It should throw an AssertionError, when the view is not attached',
          () {
        final MyPresenter myPresenter = MyPresenter();
        final MyView myView = MyView();

        expect(() => myPresenter.detachView(myView), throwsAssertionError);
      });

      test(
          'It should throw an AssertionError, when the presenter has been disposed',
          () {
        myPresenter.dispose();

        expect(() => myPresenter.detachView(null), throwsAssertionError);
      });
    });

    group('dispose()', () {
      test(
          'It should throw an AssertionError, when the presenter has been disposed',
          () {
        myPresenter.dispose();

        expect(() => myPresenter.dispose(), throwsAssertionError);
      });
    });

    group('updateView()', () {
      test('It should call the updateView callback for each view attached', () {
        final MyView myViewA = MyView();
        final MyView myViewB = MyView();

        bool wasCalledA = false;
        bool wasCalledB = false;

        setViewUpdateCallback(myViewA, (final VoidCallback callback) {
          wasCalledA = true;
        });

        setViewUpdateCallback(myViewB, (final VoidCallback callback) {
          wasCalledB = true;
        });

        myPresenter.attachView(myViewA);
        myPresenter.attachView(myViewB);

        myPresenter.updateView(() {});

        expect(wasCalledA, true);
        expect(wasCalledB, true);
      });

      test(
          'It should throw an AssertionError, when the presenter has no views attached',
          () {
        expect(() => myPresenter.updateView(() {}), throwsAssertionError);
      });

      test(
          'It should throw an AssertionError, when the presenter has been disposed',
          () {
        myPresenter.dispose();

        expect(() => myPresenter.updateView(() {}), throwsAssertionError);
      });
    });
  });

  group('setPresenterOptions()', () {
    test('It should assign given options to given presenter', () {
      final MyPresenter myPresenter = MyPresenter();

      expect(myPresenter.options, null);

      setPresenterOptions(myPresenter, 'test');

      expect(myPresenter.options, 'test');
    });

    test(
        'It should throw an AssertionError, when the presenter has been disposed',
        () {
      myPresenter.dispose();

      expect(
          () => setPresenterOptions(myPresenter, 'test'), throwsAssertionError);
    });
  });
}

class MyPresenter extends Presenter<String> {}

class MyView extends View<MyPresenter> {
  @override
  Widget createView() => Container();
}
