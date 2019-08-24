// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';

import '../_private.dart';

class ProviderGenerator extends GeneratorForAnnotation<Provider> {
  @override
  String generateForAnnotatedElement(final Element element,
      final ConstantReader annotation, final BuildStep buildStep) {
    return 'mama';
  }
}
