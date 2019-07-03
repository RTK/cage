// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:meta/meta.dart';

/// Token class used to be associated with actions.
///
/// Extends [_Token].
///
/// Marked immutable.
@immutable
class ActionToken extends TransactionToken {
  @literal
  const ActionToken(final String value)
      : assert(value != null),
        assert(value != ''),
        super('AC_$value');
}

/// Token class used to be associated with mutations.
///
/// Extends [_Token].
///
/// Marked immutable.
@immutable
class MutationToken extends TransactionToken {
  @literal
  const MutationToken(final String value)
      : assert(value != null),
        assert(value != ''),
        super('MT_$value');
}

/// Base class for [ActionToken] and [MutationToken].
///
/// Is maked immutable.
@immutable
@visibleForTesting
class TransactionToken {
  /// References the value used to compare [_Token].
  final String value;

  /// Public constructor, assigning the [value].
  ///
  /// If [value] is null, an [AssertionError] is thrown.
  @literal
  const TransactionToken(this.value)
      : assert(value != null),
        assert(value != '');

  /// Compare operator overload.
  ///
  /// Returns true, if both objects are identical.
  /// Returns true, if the runtimeTypes are equal and its [value]s are equal.
  /// Returns true, if both object's [hasCode] are equal.
  @override
  bool operator ==(final dynamic other) {
    if (identical(this, other)) {
      return true;
    } else if (other.runtimeType == runtimeType) {
      return other.value == value;
    }

    return false;
  }

  /// Returns the hashCode from the [value].
  @override
  int get hashCode => value.hashCode;

  /// Returns the [value].
  @override
  String toString() => value;
}
