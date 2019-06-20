part of cage.di;

/// used to create injection tokens
/// immutable and compile-time constant
///
/// the token value must not be null nor empty
@immutable
class InjectionToken {
  final String token;

  @literal
  const InjectionToken(this.token) : assert(token != null && token.length > 0);
}
