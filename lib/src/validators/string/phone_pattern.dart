import 'package:validart/src/phone_format.dart';
import 'package:validart/src/v_code.dart';

/// A pluggable phone-number validation strategy.
///
/// Implement this class to plug country-specific phone validation into
/// [VString.phone]. The default implementation is [E164PhonePattern].
///
/// ```dart
/// class MyCountryPhonePattern extends PhonePattern {
///   const MyCountryPhonePattern();
///
///   @override
///   String get code => 'invalid_phone_mycountry';
///
///   @override
///   Map<String, dynamic>? validate(String value) {
///     // Return null on success, or {} / {param: value} on failure.
///     return _regex.hasMatch(value) ? null : {};
///   }
/// }
///
/// V.string().phone(pattern: const MyCountryPhonePattern());
/// ```
abstract class PhonePattern {
  /// Creates a [PhonePattern].
  const PhonePattern();

  /// The error code used for locale translation lookup on failure.
  String get code;

  /// Validates [value]. Returns `null` on success, or a map with
  /// interpolation parameters on failure (empty map if no params).
  Map<String, dynamic>? validate(String value);
}

/// Default phone pattern — validates E.164 format (`+` followed by 2–15
/// digits).
///
/// Accepts numbers like `+5511999999999` or `+14155552671`.
///
/// The [countryCode] field controls whether the leading `+` is required,
/// optional (default) or forbidden — useful when collecting numbers from
/// a form that already scopes the country.
///
/// ```dart
/// V.string().phone(); // `+` optional
///
/// V.string().phone(
///   pattern: const E164PhonePattern(
///     countryCode: CountryCodeFormat.required,
///   ),
/// );
/// ```
class E164PhonePattern extends PhonePattern {
  /// Whether the leading country code (`+`) must be present, is optional,
  /// or must be absent. Defaults to [CountryCodeFormat.optional].
  final CountryCodeFormat countryCode;

  /// Creates an [E164PhonePattern].
  const E164PhonePattern({this.countryCode = CountryCodeFormat.optional});

  @override
  String get code => VCode.invalidPhone;

  @override
  Map<String, dynamic>? validate(String value) {
    final regex = switch (countryCode) {
      CountryCodeFormat.required => RegExp(r'^\+[1-9]\d{1,14}$'),
      CountryCodeFormat.optional => RegExp(r'^\+?[1-9]\d{1,14}$'),
      CountryCodeFormat.none => RegExp(r'^[1-9]\d{1,14}$'),
    };

    return regex.hasMatch(value) ? null : {};
  }
}
