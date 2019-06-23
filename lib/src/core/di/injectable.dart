// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:meta/meta.dart';

import 'injection_token.dart';

@immutable
class Injectable {
  final bool denyOverwrite;

  final InjectionToken injectionToken;

  final Object instance;

  @literal
  const Injectable(this.injectionToken, this.instance,
      {this.denyOverwrite = false});
}
