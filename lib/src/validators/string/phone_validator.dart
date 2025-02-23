import 'package:validart/src/enums/area_code_format.dart';
import 'package:validart/src/enums/country_code_format.dart';
import 'package:validart/src/enums/phone_type.dart';
import 'package:validart/src/enums/validation_mode.dart';
import 'package:validart/src/extensions/string_extensions.dart';
import 'package:validart/src/extensions/validation_mode_extensions.dart';
import 'package:validart/src/validators/validator.dart';

/// A validator for phone numbers with support for different country and area codes.
///
/// The `PhoneValidator` ensures that the input string matches a specific phone number format,
/// considering country code and area code configurations.
///
/// ## Supported Formats
/// - Country code (e.g., `+1`, `+55`) can be **required**, **optional**, or **ignored**.
/// - Area code (e.g., `(11)`, `(305)`) can be **required**, **optional**, or **ignored**.
/// - Works with different phone formats based on the selected `PhoneType`.
///
/// ## Validation Modes
/// - `ValidationMode.formatted`: Expects the phone number in a **formatted** way (e.g., `+1 (305) 123-4567`).
/// - `ValidationMode.unformatted` (default): Removes **non-digit characters** (e.g., `13051234567`).
///
/// ### Example
/// ```dart
/// final validator = PhoneValidator(
///   PhoneType.brazil,
///   message: 'Invalid Brazilian phone number',
///   areaCode: AreaCodeFormat.required,
///   countryCode: CountryCodeFormat.optional,
/// );
///
/// print(validator.validate('+55 11 98765-4321')); // null (valid)
/// print(validator.validate('11 98765-4321'));     // null (valid)
/// print(validator.validate('98765-4321'));       // 'Invalid Brazilian phone number' (invalid)
/// print(validator.validate('invalid-number'));   // 'Invalid Brazilian phone number' (invalid)
/// ```
///
/// ### Parameters
/// - [type]: The type of phone number format to validate (e.g., `PhoneType.brazil`, `PhoneType.usa`).
/// - [message]: The error message if validation fails.
/// - [areaCode]: Defines whether the area code is **required**, **optional**, or **not allowed**.
/// - [countryCode]: Defines whether the country code is **required**, **optional**, or **not allowed**.
/// - [mode]: Determines if the input should be validated as **formatted** or **unformatted**.
///
/// ## Behavior:
/// - Constructs a **dynamic regex pattern** based on the selected phone type.
/// - Supports **international numbers** (e.g., `+44 20 7946 0958` for the UK).
/// - If the input is `null` or doesn't match the expected pattern, validation fails.
class PhoneValidator extends ValidatorWithMessage<String> {
  /// Defines whether the phone number should be validated in **formatted** or **unformatted** mode.
  final ValidationMode mode;

  /// The expected phone number format (e.g., Brazilian, US, etc.).
  final PhoneType type;

  /// Defines whether the **area code** is required, optional, or ignored.
  ///
  /// Defaults to `AreaCodeFormat.required`.
  final AreaCodeFormat areaCode;

  /// Defines whether the **country code** (e.g., `+1`, `+55`) is required, optional, or ignored.
  ///
  /// Defaults to `CountryCodeFormat.none`.
  final CountryCodeFormat countryCode;

  /// Creates a `PhoneValidator` with the given phone type, area code, and country code format.
  ///
  /// ```dart
  /// final validator = PhoneValidator(
  ///   PhoneType.usa,
  ///   message: 'Invalid US phone number',
  ///   areaCode: AreaCodeFormat.required,
  ///   countryCode: CountryCodeFormat.required,
  /// );
  ///
  /// print(validator.validate('+1 (305) 555-1234')); // null (valid)
  /// print(validator.validate('305 555-1234'));     // 'Invalid US phone number' (invalid, missing country code)
  /// ```
  PhoneValidator(
    this.type, {
    required super.message,
    this.areaCode = AreaCodeFormat.required,
    this.countryCode = CountryCodeFormat.none,
    this.mode = ValidationMode.unformatted,
  });

  @override
  String? validate(covariant String value) {
    String phone = mode.isUnformatted ? value.onlyDigits : value;

    if (RegExp(_pattern).hasMatch(phone)) return null;

    return message;
  }

  String get _pattern {
    String pattern = r'^';

    pattern += _getCountryCodePattern;
    pattern += _getAreaCodePattern;
    pattern += type.pattern;
    pattern += r'$';

    return mode.isFormatted
        ? pattern
        : pattern.replaceAll(RegExp(r'\\\+|-|\\s|\\\(|\\\)|\?|\|'), '');
  }

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
