// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:cage/cage.dart';

import 'app_meta.dart';

import '../../services/text_service.dart';

class AppPresenter extends Presenter implements App {
  final TextService textService;

  String text = 'Hello World';

  AppPresenter(this.textService);
}
