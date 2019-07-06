// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:cage/cage.dart';

import 'services/text_service.dart';
import 'widgets/app/app_widget.dart';

final Module appModule = Module(const ModuleKey('Example'), services: [
  ServiceProvider.fromFactory(
      TextService, (final Injector injector) => TextService())
], widgets: [
  WidgetProvider(appWidget, dependencies: [TextService])
]);
