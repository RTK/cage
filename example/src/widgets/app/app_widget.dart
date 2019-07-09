// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:cage/cage.dart';
import 'package:flutter/widgets.dart';

import 'app_presenter.dart';
import 'app_view.dart';

import '../../services/text_service.dart';

final WidgetContainerFactory appWidget = WidgetContainerFactory(
    widgetKey: Key('app_widget'),
    createView: () => AppView(),
    createPresenter: (final Injector injector) =>
        AppPresenter(injector.getDependency(TextService)));
