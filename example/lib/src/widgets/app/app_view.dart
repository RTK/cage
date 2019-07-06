// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:cage/cage.dart';
import 'package:flutter/widgets.dart';

import 'app_meta.dart';

class AppView extends View<App> {
  @override
  Widget createView() {
    return Directionality(
        textDirection: TextDirection.ltr,
        child: Center(child: Text('Hello World')));
  }
}
