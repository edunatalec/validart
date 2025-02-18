import 'package:validart/src/enums/area_code_format.dart';
import 'package:validart/src/enums/country_code_format.dart';
import 'package:validart/src/enums/phone_type.dart';
import 'package:validart/src/validators/validator.dart';

/// A validator for phone numbers with support for different country and area codes.
///
/// The `PhoneValidator` ensures that the input string matches a specific phone number format,
/// considering country code and area code configurations.
///
/// ## Example usage:
/// ```dart
/// final validator = PhoneValidator(
///   PhoneType.brazil,
///   message: 'Invalid Brazilian phone number',
///   areaCode: AreaCodeFormat.required,
///   countryCode: CountryCodeFormat.none,
/// );
///
/// print(validator.validate('11 98765-4321')); // null (valid)
/// print(validator.validate('(11) 98765-4321')); // null (valid)
/// print(validator.validate('98765-4321')); // 'Invalid Brazilian phone number' (invalid)
/// ```
///
/// ## Parameters:
/// - [type]: The type of phone number format to validate (e.g., `PhoneType.brazil`).
/// - [message]: The error message if validation fails.
/// - [areaCode]: Defines whether the area code is required, optional, or not allowed.
/// - [countryCode]: Defines whether the country code is required, optional, or not allowed.
///
/// ## Behavior:
/// - The validator constructs a regex pattern based on the selected phone type.
/// - It considers optional or required country/area codes.
/// - If the input value is `null`, validation fails.
class PhoneValidator extends Validator<String> {
  /// The expected phone number format (e.g., Brazilian, US, etc.).
  final PhoneType type;

  /// Defines whether the area code is required, optional, or not allowed.
  ///
  /// Defaults to `AreaCodeFormat.required`.
  final AreaCodeFormat areaCode;

  /// Defines whether the country code is required, optional, or not allowed.
  ///
  /// Defaults to `CountryCodeFormat.none`.
  final CountryCodeFormat countryCode;

  /// Creates a `PhoneValidator` with the given phone type, area code, and country code format.
  PhoneValidator(
    this.type, {
    required super.message,
    this.areaCode = AreaCodeFormat.required,
    this.countryCode = CountryCodeFormat.none,
  });

  /// Validates whether the given [value] matches the expected phone number format.
  ///
  /// - The pattern is dynamically generated based on `type`, `areaCode`, and `countryCode`.
  /// - If the value is `null`, validation fails.
  ///
  /// Returns `null` if valid, otherwise returns the error message.
  @override
  String? validate(covariant String value) {
    final pattern = _buildPattern();

    if (RegExp(pattern).hasMatch(value)) return null;

    return message;
  }

  /// Constructs a regex pattern based on the selected phone type, area code, and country code.
  String _buildPattern() {
    String pattern = '^';

    pattern += _getCountryCodePattern;
    pattern += _getAreaCodePattern;
    pattern += type.pattern;
    pattern += r'$';

    return pattern;
  }

  /// Returns the appropriate regex pattern for the country code based on `CountryCodeFormat`.
  String get _getCountryCodePattern {
    switch (countryCode) {
      case CountryCodeFormat.required:
        return type.countryCode;
      case CountryCodeFormat.optional:
        return '(${type.countryCode})?';
      case CountryCodeFormat.none:
        return '';
    }
  }

  /// Returns the appropriate regex pattern for the area code based on `AreaCodeFormat`.
  String get _getAreaCodePattern {
    switch (areaCode) {
      case AreaCodeFormat.required:
        return type.areaCode;
      case AreaCodeFormat.optional:
        return '(${type.areaCode})?';
      case AreaCodeFormat.none:
        return '';
    }
  }
}
