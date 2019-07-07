// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:cage/cage.dart' as Public;
import 'package:cage/src/_private.dart' hide State;
import 'package:flutter/src/foundation/diagnostics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  MyView myView;
  MyPresenter myPresenter;

  setUp(() {
    myView = MyView();
    myPresenter = MyPresenter();
  });

  group('class View', () {
    test('It should create', () {
      expect(myView, isNotNull);
    });

    group('attachPresenter()', () {
      test('It should set the view\'s presenter to given presenter', () {
        expect(myView.presenter, null);

        expect(myView.hasPresenter, false);

        myView.attachPresenter(myPresenter);

        expect(myView.presenter, myPresenter);
        expect(myView.hasPresenter, true);
      });

      test(
          'It should throw an AssertionError, when a presenter is already attached',
          () {
        myView.attachPresenter(myPresenter);
        expect(() => myView.attachPresenter(myPresenter), throwsAssertionError);
      });

      test('It should throw an AssertionError, when the view has been disposed',
          () {
        myView.dispose();
        expect(() => myView.attachPresenter(myPresenter), throwsAssertionError);
      });
    });

    group('detachPresenter()', () {
      test('It should detach the presenter from the view', () {
        myView.attachPresenter(myPresenter);
        expect(myView.hasPresenter, true);

        myView.detachPresenter();

        expect(myView.presenter, null);
        expect(myView.hasPresenter, false);
      });

      test(
          'It should throw an AssertionError, when there is no presenter attached',
          () {
        expect(() => myView.detachPresenter(), throwsAssertionError);
      });

      test('It should throw an AssertionError, when the view has been disposed',
          () {
        myView.attachPresenter(myPresenter);
        myView.dispose();
        expect(() => myView.detachPresenter(), throwsAssertionError);
      });
    });

    group('dispose()', () {
      test('It should set the presenter to null', () {
        myView.attachPresenter(myPresenter);

        myView.dispose();

        expect(myView.presenter, null);
      });

      test('It should throw an AssertionError, when the view has been disposed',
          () {
        myView.dispose();

        expect(() => myView.dispose(), throwsAssertionError);
      });
    });

    group('spawnWidget()', () {
      test('It should throw an AssertionError, when the view has been disposed',
          () {
        myView.dispose();

        expect(() => myView.spawnWidget(MyWidgetContainerFactory()),
            throwsAssertionError);
      });

      test(
          'It should throw an AssertionError, when the widgetCreatorCallback is null',
          () {
        expect(myView.widgetCreatorCallback, null);

        expect(() => myView.spawnWidget(MyWidgetContainerFactory()),
            throwsAssertionError);
      });

      test(
          'It should throw an AssertionError, when given widgetContainerFactory  is null',
          () {
        final FunctionsStub fnStub = FunctionsStub();

        setViewWidgetCreatorCallback(myView, fnStub.createWidget);

        expect(myView.widgetCreatorCallback, fnStub.createWidget);
        expect(() => myView.spawnWidget(null), throwsAssertionError);
      });

      test(
          'It should call the widgetCreatorCallback with given WidgetContainerFactory and options and return the view\'s widget',
          () {
        final FunctionsStub fnStub = FunctionsStub();
        final MyWidgetContainerFactory myWidgetContainerFactory =
            MyWidgetContainerFactory();

        setViewWidgetCreatorCallback(myView, fnStub.createWidget);

        final Widget widget =
            myView.spawnWidget(myWidgetContainerFactory, widgetOptions: 'test');

        expect(fnStub.createWidgetToken, Key('MyWidget'));
        expect(fnStub.createWidgetOptions, 'test');
        expect(widget is StatefulWidgetContainer, true);
      });

      test(
          'It should get the widget from cache, when the same factory is spawned',
          () {
        final FunctionsStub fnStub = FunctionsStub();
        final MyWidgetContainerFactory myWidgetContainerFactory =
            MyWidgetContainerFactory();

        setViewWidgetCreatorCallback(myView, fnStub.createWidget);

        myView.spawnWidget(myWidgetContainerFactory, widgetOptions: 'test');
        expect(fnStub.callCounter, 1);

        myView.spawnWidget(myWidgetContainerFactory, widgetOptions: 'test');
        expect(fnStub.callCounter, 1);

        myView.spawnWidget(myWidgetContainerFactory, widgetOptions: 'test2');
        expect(fnStub.callCounter, 2);
      });
    });
  });

  group('setViewBuildContext()', () {
    test('It should set the build context of the view correctly', () {
      final MyBuildContext ctx = MyBuildContext();

      setViewBuildContext(myView, ctx);

      expect(myView.buildContext, ctx);
    });

    test('It should throw an AssertionError, when the view has been disposed',
        () {
      myView.dispose();

      expect(() => setViewBuildContext(myView, MyBuildContext()),
          throwsAssertionError);
    });
  });

  group('setViewUpdateCallback()', () {
    FunctionsStub fnStub;

    setUp(() {
      fnStub = FunctionsStub();
    });

    test('It should set the updateCallback of given view to given value', () {
      setViewUpdateCallback(myView, fnStub.updateCallback);

      expect(myView.updateCallback, fnStub.updateCallback);
    });

    test('It should throw an AssertionError, when the view has been disposed',
        () {
      myView.dispose();

      expect(() => setViewUpdateCallback(myView, fnStub.updateCallback),
          throwsAssertionError);
    });

    test(
        'It should throw an AssertionError, when the callback already has been set',
        () {
      setViewUpdateCallback(myView, fnStub.updateCallback);

      expect(() => setViewUpdateCallback(myView, fnStub.updateCallback),
          throwsAssertionError);
    });
  });

  group('setViewWidgetCreatorCallback()', () {
    FunctionsStub fnStub;

    setUp(() {
      fnStub = FunctionsStub();
    });

    test('It should set the view\'s creatorCallback to given value', () {
      setViewWidgetCreatorCallback(myView, fnStub.createWidget);

      expect(myView.widgetCreatorCallback, fnStub.createWidget);
    });

    test('It should throw an AssertionError, when the view has been disposed',
        () {
      myView.dispose();

      expect(() => setViewWidgetCreatorCallback(myView, fnStub.createWidget),
          throwsAssertionError);
    });

    test(
        'It should throw an AssertionError, when the view already has a creatorCallback assigned',
        () {
      setViewWidgetCreatorCallback(myView, fnStub.createWidget);
      expect(() => setViewWidgetCreatorCallback(myView, fnStub.createWidget),
          throwsAssertionError);
    });
  });

  group('updateViewFromPresenter()', () {
    FunctionsStub fnStub;

    setUp(() {
      fnStub = FunctionsStub();
    });

    test('It should call the view\'s updateCallback', () {
      setViewUpdateCallback(myView, fnStub.updateCallback);

      expect(fnStub.updateCallbackCalled, false);

      updateViewFromPresenter(myView, () {});

      expect(fnStub.updateCallbackCalled, true);
    });

    test('It should throw an AssertionError, when the view has been disposed',
        () {
      myView.dispose();

      expect(
          () => updateViewFromPresenter(myView, () {}), throwsAssertionError);
    });
  });
}

class MyPresenter extends Presenter<void> {}

class MyView extends View<MyPresenter> {
  @override
  createView() => Container();
}

class MyWidgetContainerFactory extends WidgetContainerFactory {
  MyWidgetContainerFactory()
      : super(
            widgetKey: Key('MyWidget'),
            createPresenter: (final Public.Injector injector) => MyPresenter(),
            createView: () => MyView());
}

class MyBuildContext extends BuildContext {
  @override
  InheritedElement ancestorInheritedElementForWidgetOfExactType(
          Type targetType) =>
      null;

  @override
  RenderObject ancestorRenderObjectOfType(TypeMatcher matcher) => null;

  @override
  State<StatefulWidget> ancestorStateOfType(TypeMatcher matcher) => null;

  @override
  Widget ancestorWidgetOfExactType(Type targetType) => null;

  @override
  RenderObject findRenderObject() => null;

  @override
  InheritedWidget inheritFromElement(InheritedElement ancestor,
          {Object aspect}) =>
      null;

  @override
  InheritedWidget inheritFromWidgetOfExactType(Type targetType,
          {Object aspect}) =>
      null;

  @override
  BuildOwner get owner => null;

  @override
  State<StatefulWidget> rootAncestorStateOfType(TypeMatcher matcher) => null;

  @override
  Size get size => null;

  @override
  void visitAncestorElements(bool Function(Element element) visitor) {}

  @override
  void visitChildElements(visitor) {}

  @override
  Widget get widget => null;

  @override
  DiagnosticsNode describeElement(String name,
          {DiagnosticsTreeStyle style = DiagnosticsTreeStyle.errorProperty}) =>
      null;

  @override
  List<DiagnosticsNode> describeMissingAncestor({Type expectedAncestorType}) =>
      null;

  @override
  DiagnosticsNode describeOwnershipChain(String name) => null;

  @override
  DiagnosticsNode describeWidget(String name,
          {DiagnosticsTreeStyle style = DiagnosticsTreeStyle.errorProperty}) =>
      null;
}

class FunctionsStub {
  Key createWidgetToken;
  Object createWidgetOptions;

  int callCounter = 0;

  bool updateCallbackCalled = false;

  WidgetContainer createWidget(final Key widgetToken,
      [final Object widgetOptions]) {
    callCounter++;

    createWidgetToken = widgetToken;
    createWidgetOptions = widgetOptions;

    return WidgetContainer(widgetToken, MyPresenter(), MyView(), null);
  }

  void updateCallback(final VoidCallback callback) {
    updateCallbackCalled = true;
  }
}
