/*
 * Copyright Rouven T. Kruse. All rights reserved.
 * Use of this source code is governed by an MIT-style license that can be
 * found in the LICENSE file.
 */

import 'package:build/build.dart';
import 'package:cage_build/src/generators/provider_generator.dart';
import 'package:source_gen/source_gen.dart';

Builder providerBuilder(BuilderOptions options) =>
    SharedPartBuilder([ProviderGenerator()], 'provider_builder');
