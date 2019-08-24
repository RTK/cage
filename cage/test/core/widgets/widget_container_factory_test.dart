// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:cage/cage.dart' as Public;
import 'package:cage/src/_private.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  WidgetContainerFactory wcf;

  setUp(() {
    wcf = WidgetContainerFactory(
        widgetKey: Key('wcf'),
        createView: () => V(),
        createPresenter: (final Public.Injector injector) => P());
  });

  group('class WidgetContainerFactory', () {
    test('An instance shall be created', () {
      expect(wcf, isNotNull);
    });

    test(
        'It should throw an AssertionError, when the createPresenter callback is null',
        () {
      expect(
          () => WidgetContainerFactory(
              widgetKey: Key('test'),
              createView: () => V(),
              createPresenter: null),
          throwsAssertionError);
    });

    test(
        'It should throw an AssertionError, when the createView callback is null',
        () {
      expect(
          () => WidgetContainerFactory(
              widgetKey: Key('test'),
              createPresenter: (final Public.Injector injector) => P(),
              createView: null),
          throwsAssertionError);
    });

    test('It should throw an AssertionError, when the widgetKey is null', () {
      expect(
          () => WidgetContainerFactory(
              widgetKey: null,
              createPresenter: (final Public.Injector injector) => P(),
              createView: () => V()),
          throwsAssertionError);
    });
  });

  group('createWidgetContainer()', () {
    test('It should create the WidgetContainer instance', () {
      expect(createWidgetContainer(wcf, null, 'test'),
          isInstanceOf<WidgetContainer>());
    });
  });
}

class P extends Presenter {}

class V extends View<P> {
  @override
  Widget createView() => Container();
}
