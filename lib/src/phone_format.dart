/// Controls whether a leading international dialing code (e.g. `+1`,
/// `+55`, `+44`) is expected on a phone number.
///
/// Used by phone patterns that accept E.164-style numbers to pin the
/// presence of the country code.
///
/// ```dart
/// V.string().phone(
///   patterns: [
///     const E164PhonePattern(countryCode: CountryCodeFormat.required),
///   ],
/// );
/// ```
enum CountryCodeFormat {
  /// The country code (leading `+`) must be present.
  required,

  /// The country code is optional.
  optional,

  /// The country code must be absent.
  none,
}
