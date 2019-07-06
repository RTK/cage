// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:meta/meta.dart';

/// [InjectionToken] class, used to create token for DI ([Injector]).
///
/// [InjectionToken] are immutable and can be used as compile-time constants.
@immutable
class InjectionToken {
  final String token;

  /// The hash code is resolved by using the [token]'s hashCode.
  ///
  /// This way an [InjectionToken] using the [token] 'A' will resolve equal
  /// to the String 'A'.
  @override
  int get hashCode => token.hashCode;

  @literal
  const InjectionToken(this.token) : assert(token != null && token.length > 0);

  /// Generates an [InjectionToken] at runtime (no constant) using the given
  /// [base].
  ///
  /// The [base] argument can be of any [Type] ([Object]).
  ///
  /// If the [base] already is an [InjectionToken] it will be returned unmodified.
  ///
  /// If the [base] is a [String], a new [InjectionToken] will be generated, using
  /// the [base] as token value.
  ///
  /// If [base] is null, an [Exception] is thrown.
  ///
  /// Otherwise the [base] toString() method will be invoked, its returned
  /// [String] value used to generate a new [InjectionToken].
  static InjectionToken generateFromObject(final Object base) {
    if (base is InjectionToken) {
      return base;
    } else if (base is String) {
      return InjectionToken(base);
    }

    assert(base != null);

    return InjectionToken(base.toString());
  }

  /// Provides the functionality to compare [InjectionToken].
  ///
  /// If the compared object is identical, equality is verified.
  ///
  /// If the compared Object is an [InjectionToken] as well, equality is given
  /// when both [token] are equal (not identical!).
  ///
  /// Otherwise the hashCode must be equal to verify equality.
  @override
  bool operator ==(final dynamic other) {
    if (identical(other, this)) {
      return true;
    }

    if (other is InjectionToken) {
      return other.token == token;
    }

    return false;
  }

  @override
  String toString() => token;
}
