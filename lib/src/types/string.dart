import 'package:validart/src/enums/area_code_format.dart';
import 'package:validart/src/enums/case_sensitivity.dart';
import 'package:validart/src/enums/country_code_format.dart';
import 'package:validart/src/enums/phone_type.dart';
import 'package:validart/src/enums/uuid_version.dart';
import 'package:validart/src/messages/string_message.dart';
import 'package:validart/src/types/any_every.dart';
import 'package:validart/src/validators/required_validator.dart';
import 'package:validart/src/validators/string/cep_validator.dart';
import 'package:validart/src/validators/string/cnpj_validator.dart';
import 'package:validart/src/validators/string/contains_validator.dart';
import 'package:validart/src/validators/string/cpf_validator.dart';
import 'package:validart/src/validators/string/date_validator.dart';
import 'package:validart/src/validators/string/email_validator.dart';
import 'package:validart/src/validators/string/ends_with_validator.dart';
import 'package:validart/src/validators/string/equals_validator.dart';
import 'package:validart/src/validators/string/ip_validator.dart';
import 'package:validart/src/validators/string/max_length_validator.dart';
import 'package:validart/src/validators/string/min_length_validator.dart';
import 'package:validart/src/validators/string/pattern_validator.dart';
import 'package:validart/src/validators/string/phone_validator.dart';
import 'package:validart/src/validators/string/starts_with_validator.dart';
import 'package:validart/src/validators/string/time_validator.dart';
import 'package:validart/src/validators/string/url_validator.dart';
import 'package:validart/src/validators/string/uuid_validator.dart';
import 'package:validart/src/validators/validator.dart';

/// `VString` is a validation class for `String` values in Validart.
///
/// Example usage:
/// ```dart
/// final validator = v.string().email();
/// print(validator.validate('test@example.com')); // true
/// print(validator.validate('invalid-email')); // false
/// ```
class VString extends VAnyEvery<String> {
  final StringMessage _message;

  /// Creates an instance of `VString` with the specified validation messages.
  ///
  /// The `message` parameter allows overriding the default "required" validation message.
  VString(this._message, {required String? message}) {
    add(RequiredValidator(message: message ?? _message.required));
  }

  /// Adds a validator to the `VString` instance.
  ///
  /// Allows chaining multiple string validations.
  @override
  VString add(Validator<String> validator) {
    super.add(validator);
    return this;
  }

  /// Ensures the string is a valid email.
  VString email({String? message}) {
    return add(EmailValidator(message: message ?? _message.email));
  }

  /// Ensures the string is a valid UUID.
  ///
  /// Supports different UUID versions via the `version` parameter (default is v4).
  VString uuid({UUIDVersion? version, String? message}) {
    return add(
      UUIDValidator(
        message: message ?? _message.uuid,
        version: version ?? UUIDVersion.v4,
      ),
    );
  }

  /// Ensures the string is a valid URL.
  VString url({String? message}) {
    return add(UrlValidator(message: message ?? _message.url));
  }

  /// Ensures the string is a valid CPF (Brazil).
  VString cpf({String? message}) {
    return add(CPFValidator(message: message ?? _message.cpf));
  }

  /// Ensures the string is a valid CNPJ (Brazil).
  VString cnpj({String? message}) {
    return add(CNPJValidator(message: message ?? _message.cnpj));
  }

  /// Ensures the string is a valid postal code (CEP - Brazil).
  VString cep({String? message}) {
    return add(CEPValidator(message: message ?? _message.cep));
  }

  /// Ensures the string has at least `minLength` characters.
  VString min(int minLength, {String? message}) {
    return add(
      MinLengthValidator(
        minLength,
        message: message ?? _message.min(minLength),
      ),
    );
  }

  /// Ensures the string does not exceed `maxLength` characters.
  VString max(int maxLength, {String? message}) {
    return add(
      MaxLengthValidator(
        maxLength,
        message: message ?? _message.max(maxLength),
      ),
    );
  }

  /// Ensures the string matches a phone number format for a given `PhoneType`.
  VString phone(
    PhoneType type, {
    String? message,
    AreaCodeFormat areaCode = AreaCodeFormat.required,
    CountryCodeFormat countryCode = CountryCodeFormat.none,
  }) {
    return add(
      PhoneValidator(
        type,
        message: message ?? _message.phone,
        areaCode: areaCode,
        countryCode: countryCode,
      ),
    );
  }

  /// Ensures the string follows a valid time format (e.g., `HH:mm:ss`).
  VString time({String? message}) {
    return add(TimeValidator(message: message ?? _message.time));
  }

  /// Ensures the string is a valid IP address (IPv4 or IPv6).
  VString ip({String? message}) {
    return add(IPValidator(message: message ?? _message.ip));
  }

  /// Ensures the string represents a valid date format.
  VString date({String? message}) {
    return add(DateValidator(message: message ?? _message.date));
  }

  /// Ensures the string contains a specific substring.
  VString contains(
    String data, {
    String? message,
    CaseSensitivity caseSensitivity = CaseSensitivity.sensitive,
  }) {
    return add(
      ContainsValidator(
        data,
        message: message ?? _message.contains(data),
        caseSensitivity: caseSensitivity,
      ),
    );
  }

  /// Ensures the string is equal to a specific value.
  VString equals(
    String data, {
    String? message,
    CaseSensitivity caseSensitivity = CaseSensitivity.sensitive,
  }) {
    return add(
      EqualsValidator(
        data,
        message: message ?? _message.equals(data),
        caseSensitivity: caseSensitivity,
      ),
    );
  }

  /// Ensures the string starts with a given prefix.
  VString startsWith(
    String prefix, {
    String? message,
    CaseSensitivity caseSensitivity = CaseSensitivity.sensitive,
  }) {
    return add(
      StartsWithValidator(
        prefix,
        message: message ?? _message.startsWith(prefix),
        caseSensitivity: caseSensitivity,
      ),
    );
  }

  /// Ensures the string ends with a given suffix.
  VString endsWith(
    String sufix, {
    String? message,
    CaseSensitivity caseSensitivity = CaseSensitivity.sensitive,
  }) {
    return add(
      EndsWithValidator(
        sufix,
        message: message ?? _message.endsWith(sufix),
        caseSensitivity: caseSensitivity,
      ),
    );
  }

  /// Ensures the string matches a given regex pattern.
  VString pattern(String pattern, {String? message}) {
    return add(PatternValidator(pattern, message: message ?? _message.pattern));
  }

  /// Ensures the string matches at least one of the given validators.
  @override
  VString any(covariant List<VString> types, {String? message}) {
    super.any(types, message: message ?? _message.any);
    return this;
  }

  /// Ensures the string passes all of the given validators.
  @override
  VString every(covariant List<VString> types, {String? message}) {
    super.every(types, message: message ?? _message.every);
    return this;
  }

  /// Marks the string as optional.
  @override
  VString optional() {
    super.optional();
    return this;
  }

  /// Marks the string as nullable.
  @override
  VString nullable() {
    super.nullable();
    return this;
  }

  /// Adds a custom validation rule using a refine function.
  ///
  /// Example:
  /// ```dart
  /// final validator = v.string().refine(
  ///   (value) => value != null && value.length > 5,
  ///   message: 'Must be longer than 5 characters',
  /// );
  /// ```
  @override
  VString refine(bool Function(String data) validator, {String? message}) {
    super.refine(validator, message: message ?? _message.refine);
    return this;
  }
}
