import 'package:keeper/src/enums/area_code_format.dart';
import 'package:keeper/src/enums/case_sensitivity.dart';
import 'package:keeper/src/enums/country_code_format.dart';
import 'package:keeper/src/enums/phone_type.dart';
import 'package:keeper/src/enums/uuid_version.dart';
import 'package:keeper/src/messages/string_message.dart';
import 'package:keeper/src/types/refine.dart';
import 'package:keeper/src/validators/required_validator.dart';
import 'package:keeper/src/validators/string/cep_validator.dart';
import 'package:keeper/src/validators/string/cnpj_validator.dart';
import 'package:keeper/src/validators/string/contains_validator.dart';
import 'package:keeper/src/validators/string/cpf_validator.dart';
import 'package:keeper/src/validators/string/date_validator.dart';
import 'package:keeper/src/validators/string/email_validator.dart';
import 'package:keeper/src/validators/string/ends_with_validator.dart';
import 'package:keeper/src/validators/string/equals_validator.dart';
import 'package:keeper/src/validators/string/ip_validator.dart';
import 'package:keeper/src/validators/string/max_length_validator.dart';
import 'package:keeper/src/validators/string/min_length_validator.dart';
import 'package:keeper/src/validators/string/pattern_validator.dart';
import 'package:keeper/src/validators/string/phone_validator.dart';
import 'package:keeper/src/validators/string/starts_with_validator.dart';
import 'package:keeper/src/validators/string/time_validator.dart';
import 'package:keeper/src/validators/string/url_validator.dart';
import 'package:keeper/src/validators/string/uuid_validator.dart';
import 'package:keeper/src/validators/validator.dart';

/// `KString` is a validation class for `String` values in Keeper.
///
/// Example usage:
/// ```dart
/// final validator = k.string().email();
/// print(validator.validate('test@example.com')); // true
/// print(validator.validate('invalid-email')); // false
/// ```
class KString extends KRefine<String> {
  final StringMessage _message;

  /// Creates an instance of `KString` with the specified validation messages.
  ///
  /// The `message` parameter allows overriding the default "required" validation message.
  KString(this._message, {required String? message}) {
    add(RequiredValidator(message: message ?? _message.required));
  }

  /// Adds a validator to the `KString` instance.
  ///
  /// Allows chaining multiple string validations.
  @override
  KString add(KValidator<String> validator) {
    super.add(validator);
    return this;
  }

  /// Ensures the string is a valid email.
  KString email({String? message}) {
    return add(EmailValidator(message: message ?? _message.email));
  }

  /// Ensures the string is a valid UUID.
  ///
  /// Supports different UUID versions via the `version` parameter (default is v4).
  KString uuid({UUIDVersion? version, String? message}) {
    return add(
      UUIDValidator(
        message: message ?? _message.uuid,
        version: version ?? UUIDVersion.v4,
      ),
    );
  }

  /// Ensures the string is a valid URL.
  KString url({String? message}) {
    return add(UrlValidator(message: message ?? _message.url));
  }

  /// Ensures the string is a valid CPF (Brazil).
  KString cpf({String? message}) {
    return add(CPFValidator(message: message ?? _message.cpf));
  }

  /// Ensures the string is a valid CNPJ (Brazil).
  KString cnpj({String? message}) {
    return add(CNPJValidator(message: message ?? _message.cnpj));
  }

  /// Ensures the string is a valid postal code (CEP - Brazil).
  KString cep({String? message}) {
    return add(CEPValidator(message: message ?? _message.cep));
  }

  /// Ensures the string has at least `minLength` characters.
  KString min(int minLength, {String? message}) {
    return add(
      MinLengthValidator(
        minLength,
        message: message ?? _message.min(minLength),
      ),
    );
  }

  /// Ensures the string does not exceed `maxLength` characters.
  KString max(int maxLength, {String? message}) {
    return add(
      MaxLengthValidator(
        maxLength,
        message: message ?? _message.max(maxLength),
      ),
    );
  }

  /// Ensures the string matches a phone number format for a given `PhoneType`.
  KString phone(
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
  KString time({String? message}) {
    return add(TimeValidator(message: message ?? _message.time));
  }

  /// Ensures the string is a valid IP address (IPv4 or IPv6).
  KString ip({String? message}) {
    return add(IPValidator(message: message ?? _message.ip));
  }

  /// Ensures the string represents a valid date format.
  KString date({String? message}) {
    return add(DateValidator(message: message ?? _message.date));
  }

  /// Ensures the string contains a specific substring.
  KString contains(
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
  KString equals(
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
  KString startsWidth(
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
  KString endsWith(
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
  KString pattern(String pattern, {String? message}) {
    return add(PatternValidator(pattern, message: message ?? _message.pattern));
  }

  /// Ensures the string matches at least one of the given validators.
  @override
  KString any(covariant List<KString> types, {String? message}) {
    super.any(types, message: message ?? _message.any);
    return this;
  }

  /// Ensures the string passes all of the given validators.
  @override
  KString every(covariant List<KString> types, {String? message}) {
    super.every(types, message: message ?? _message.every);
    return this;
  }

  /// Marks the string as optional.
  @override
  KString optional() {
    super.optional();
    return this;
  }

  /// Marks the string as nullable.
  @override
  KString nullable() {
    super.nullable();
    return this;
  }

  /// Adds a custom validation rule using a refine function.
  ///
  /// Example:
  /// ```dart
  /// final validator = k.string().refine(
  ///   (value) => value != null && value.length > 5,
  ///   message: 'Must be longer than 5 characters',
  /// );
  /// ```
  @override
  KString refine(bool Function(String? data) validator, {String? message}) {
    super.refine(validator, message: message ?? _message.refine);
    return this;
  }
}
