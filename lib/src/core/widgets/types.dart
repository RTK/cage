// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.
import 'package:flutter/widgets.dart' show VoidCallback;

export 'package:flutter/widgets.dart' show VoidCallback;

typedef UpdateWidgetCallback = void Function(VoidCallback updateCallback);

typedef UpdateCallback = void Function(UpdateWidgetCallback);

typedef UpdateViewCallback = void Function(VoidCallback);
