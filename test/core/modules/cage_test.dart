// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:cage/cage.dart' as Public show Injector;
import 'package:cage/src/_private.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Injector injector;

  setUp(() {
    injector = emptyInjector.createChild(linkToParent: false);
  });

  group('class Cage', () {
    group('bootstrapWidgetFactory()', () {
      test('It should bootstrap the rootWidget correctly', () {
        final Key rootWidgetKey = Key('root');

        final WidgetContainerFactory wcf = WidgetContainerFactory(
            createPresenter: (final Public.Injector injector) => P(),
            createView: () => V(),
            widgetKey: rootWidgetKey);

        final Module module = Module(const ModuleKey('module'),
            widgets: [WidgetProvider(wcf)], rootWidget: wcf);

        final CagedModule cagedModule =
            CagedModule.fromModuleType(module, injector);

        cagedModule.bootstrapWidgets();

        final Cage cage = Cage.fromCagedModule(cagedModule);

        final WidgetContainer widgetContainer = cage.bootstrapWidgetFactory();

        expect(widgetContainer, isNotNull);
      });

      test(
          'It should throw an AssertionError, when no rootWidget is defined for root module',
          () {
        final CagedModule cagedModule = CagedModule.fromModuleType(
            Module(const ModuleKey('test')), injector);

        cagedModule.bootstrapWidgets();

        final Cage cage = Cage.fromCagedModule(cagedModule);

        expect(() => cage.bootstrapWidgetFactory(), throwsAssertionError);
      });

      test(
          'It should throw an AssertionError, when a rootWidget is defined, but the widget does not exist',
          () {
        final WidgetContainerFactory wcf = WidgetContainerFactory(
            createPresenter: (final Public.Injector injector) => P(),
            createView: () => V(),
            widgetKey: Key('test'));

        final CagedModule cagedModule = CagedModule.fromModuleType(
            Module(const ModuleKey('test'), rootWidget: wcf), injector);

        cagedModule.bootstrapWidgets();

        final Cage cage = Cage.fromCagedModule(cagedModule);

        expect(() => cage.bootstrapWidgetFactory(), throwsAssertionError);
      });
    });
  });
}

class P extends Presenter {}

class V extends View<P> {
  @override
  Widget createView() => Container();
}
