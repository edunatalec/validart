import 'package:validart/src/enums/area_code_format.dart';
import 'package:validart/src/enums/case_sensitivity.dart';
import 'package:validart/src/enums/country_code_format.dart';
import 'package:validart/src/enums/phone_type.dart';
import 'package:validart/src/enums/uuid_version.dart';
import 'package:validart/src/messages/string_message.dart';
import 'package:validart/src/types/primitive.dart';
import 'package:validart/src/types/array.dart';
import 'package:validart/src/validators/required_validator.dart';
import 'package:validart/src/validators/string/alpha_validator.dart';
import 'package:validart/src/validators/string/alphanumeric_validator.dart';
import 'package:validart/src/validators/string/card_validator.dart';
import 'package:validart/src/validators/string/cep_validator.dart';
import 'package:validart/src/validators/string/cnpj_validator.dart';
import 'package:validart/src/validators/string/contains_validator.dart';
import 'package:validart/src/validators/string/cpf_validator.dart';
import 'package:validart/src/validators/string/date_validator.dart';
import 'package:validart/src/validators/string/email_validator.dart';
import 'package:validart/src/validators/string/ends_with_validator.dart';
import 'package:validart/src/validators/string/equals_validator.dart';
import 'package:validart/src/validators/string/ip_validator.dart';
import 'package:validart/src/validators/string/jwt_validator.dart';
import 'package:validart/src/validators/string/max_length_validator.dart';
import 'package:validart/src/validators/string/min_length_validator.dart';
import 'package:validart/src/validators/string/password_validator.dart';
import 'package:validart/src/validators/string/pattern_validator.dart';
import 'package:validart/src/validators/string/phone_validator.dart';
import 'package:validart/src/validators/string/slug_validator.dart';
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
class VString extends VPrimitive<String> {
  final StringMessage _message;

  /// Creates an instance of `VString` with the specified validation messages.
  ///
  /// The `message` parameter allows overriding the default "required" validation message.
  VString(this._message, {required String? message}) {
    add(RequiredValidator(message: message ?? _message.required));
  }

  /// Ensures that the string contains only alphabetic characters (letters).
  ///
  /// This method validates whether the given string consists only of letters
  /// (A-Z, a-z) without any numbers, symbols, or spaces.
  ///
  /// Example usage:
  /// ```dart
  /// final validator = v.string().alpha();
  ///
  /// print(validator.validate("Hello")); // true
  /// print(validator.validate("Hello123")); // false
  /// print(validator.validate("Hello World")); // false
  /// print(validator.validate(null)); // false
  /// ```
  ///
  /// - [message] *(optional)* Custom error message.
  VString alpha({String? message}) {
    return add(AlphaValidator(message: message ?? _message.alpha));
  }

  /// Ensures that the string contains only alphanumeric characters (letters and numbers).
  ///
  /// This method validates whether the given string consists only of letters (A-Z, a-z)
  /// and numbers (0-9), without any symbols or spaces.
  ///
  /// Example usage:
  /// ```dart
  /// final validator = v.string().alphanumeric();
  ///
  /// print(validator.validate("Hello123")); // true
  /// print(validator.validate("Hello World")); // false
  /// print(validator.validate("Hello@123")); // false
  /// print(validator.validate(null)); // false
  /// ```
  ///
  /// - [message] *(optional)* Custom error message.
  VString alphanumeric({String? message}) {
    return add(
      AlphanumericValidator(message: message ?? _message.alphanumeric),
    );
  }

  /// Ensures that the string is a valid credit card number.
  ///
  /// This method validates whether the given string follows the standard
  /// credit card number format, checking for the correct length and structure.
  ///
  /// Example usage:
  /// ```dart
  /// final validator = v.string().card();
  ///
  /// print(validator.validate("4111111111111111")); // true (Valid Visa card)
  /// print(validator.validate("1234567812345678")); // false
  /// print(validator.validate("4111-1111-1111-1111")); // true (formatted correctly)
  /// print(validator.validate(null)); // false
  /// ```
  ///
  /// - [message] *(optional)* Custom error message.
  VString card({String? message}) {
    return add(CardValidator(message: message ?? _message.card));
  }

  /// Ensures that the string is a valid Brazilian postal code (CEP).
  ///
  /// This method validates whether the given string follows the correct CEP format,
  /// which is either `XXXXX-XXX` or `XXXXXXXX`, where `X` represents a digit.
  ///
  /// Example usage:
  /// ```dart
  /// final validator = v.string().cep();
  ///
  /// print(validator.validate("01001-000")); // true
  /// print(validator.validate("01001000")); // true
  /// print(validator.validate("00000-000")); // false
  /// print(validator.validate("invalid-cep")); // false
  /// print(validator.validate(null)); // false
  /// ```
  ///
  /// - [message] *(optional)* Custom error message.
  VString cep({String? message}) {
    return add(CEPValidator(message: message ?? _message.cep));
  }

  /// Ensures that the string is a valid CNPJ (Cadastro Nacional da Pessoa Jurídica).
  ///
  /// This method validates whether the given string is a properly formatted and valid CNPJ,
  /// which is the Brazilian national registry number for legal entities.
  ///
  /// Example usage:
  /// ```dart
  /// final validator = v.string().cnpj();
  ///
  /// print(validator.validate("12.345.678/0001-95")); // true
  /// print(validator.validate("12345678000195")); // true
  /// print(validator.validate("00.000.000/0000-00")); // false
  /// print(validator.validate("invalid-cnpj")); // false
  /// print(validator.validate(null)); // false
  /// ```
  ///
  /// - [message] *(optional)* Custom error message.
  VString cnpj({String? message}) {
    return add(CNPJValidator(message: message ?? _message.cnpj));
  }

  /// Ensures that the string contains a specific substring.
  ///
  /// This method checks whether the given string includes the specified `data`.
  /// By default, the comparison is case-sensitive, but it can be modified using
  /// the `caseSensitivity` parameter.
  ///
  /// Example usage:
  /// ```dart
  /// final validator = v.string().contains("hello");
  ///
  /// print(validator.validate("hello world")); // true
  /// print(validator.validate("HellO world")); // false (case-sensitive)
  /// print(validator.validate("world")); // false
  /// print(validator.validate(null)); // false
  ///
  /// // Case-insensitive comparison
  /// final validatorIgnoreCase = v.string().contains("hello", caseSensitivity: CaseSensitivity.insensitive);
  /// print(validatorIgnoreCase.validate("HellO world")); // true
  /// ```
  ///
  /// - [data] The expected substring that must be present in the validated string.
  /// - [message] *(optional)* Custom error message.
  /// - [caseSensitivity] *(optional)* Determines whether the comparison is case-sensitive or case-insensitive. (default: `CaseSensitivity.sensitive`)
  VString contains(
    String data, {
    String Function(String data)? message,
    CaseSensitivity caseSensitivity = CaseSensitivity.sensitive,
  }) {
    return add(
      ContainsValidator(
        data,
        message: message?.call(data) ?? _message.contains(data),
        caseSensitivity: caseSensitivity,
      ),
    );
  }

  /// Ensures that the string is a valid CPF (Cadastro de Pessoas Físicas).
  ///
  /// This method validates whether the provided string follows the CPF format,
  /// which is a Brazilian individual taxpayer registry number.
  ///
  /// Example usage:
  /// ```dart
  /// final validator = v.string().cpf();
  ///
  /// print(validator.validate("123.456.789-09")); // true
  /// print(validator.validate("12345678909")); // true
  /// print(validator.validate("000.000.000-00")); // false
  /// print(validator.validate("invalid-cpf")); // false
  /// print(validator.validate(null)); // false
  /// ```
  ///
  /// - [message] *(optional)* Custom error message.
  VString cpf({String? message}) {
    return add(CPFValidator(message: message ?? _message.cpf));
  }

  /// Ensures that the string is a valid date format.
  ///
  /// This method validates whether the given string conforms to a valid date format.
  /// The exact format may depend on the implementation of the `DateValidator`.
  ///
  /// Example usage:
  /// ```dart
  /// final validator = v.string().date();
  ///
  /// print(validator.validate("2024-05-20")); // true
  /// print(validator.validate("20/05/2024")); // true
  /// print(validator.validate("May 20, 2024")); // true
  /// print(validator.validate("invalid-date")); // false
  /// print(validator.validate(null)); // false
  /// ```
  ///
  /// - [message] *(optional)* Custom error message.
  VString date({String? message}) {
    return add(DateValidator(message: message ?? _message.date));
  }

  /// Validates that the string is a properly formatted email address.
  ///
  /// This method ensures that the string follows the standard email format.
  /// It checks for the presence of an "@" symbol, a valid domain, and a top-level domain.
  ///
  /// Example usage:
  /// ```dart
  /// final validator = v.string().email();
  ///
  /// print(validator.validate('test@example.com')); // true
  /// print(validator.validate('invalid-email')); // false
  /// print(validator.validate('user@domain')); // false
  /// print(validator.validate('user@.com')); // false
  /// ```
  ///
  /// - [message] *(optional)*: A custom error message to return if the validation fails.
  VString email({String? message}) {
    return add(EmailValidator(message: message ?? _message.email));
  }

  /// Ensures that the string ends with the specified suffix.
  ///
  /// This method validates whether the given string ends with the provided `suffix`.
  /// By default, the comparison is case-sensitive, but this can be modified using
  /// the `caseSensitivity` parameter.
  ///
  /// ## Example Usage:
  /// ```dart
  /// final validator = v.string().endsWith("world");
  ///
  /// print(validator.validate("Hello world")); // true
  /// print(validator.validate("Hello World")); // false (case-sensitive)
  /// print(validator.validate("world hello")); // false
  /// print(validator.validate(null)); // false
  ///
  /// // Case-insensitive comparison
  /// final validatorIgnoreCase = v.string().endsWith("world", caseSensitivity: CaseSensitivity.insensitive);
  /// print(validatorIgnoreCase.validate("Hello World")); // true
  /// ```
  ///
  /// [suffix] The expected ending substring.
  ///
  /// [message] *(optional)* Custom error message.
  ///
  /// [caseSensitivity] *(optional)* Defines whether the comparison is case-sensitive (default) or insensitive.
  VString endsWith(
    String sufix, {
    String Function(String sufix)? message,
    CaseSensitivity caseSensitivity = CaseSensitivity.sensitive,
  }) {
    return add(
      EndsWithValidator(
        sufix,
        message: message?.call(sufix) ?? _message.endsWith(sufix),
        caseSensitivity: caseSensitivity,
      ),
    );
  }

  /// Ensures that the string is exactly equal to the specified value.
  ///
  /// This method validates whether the given string matches the provided `data`
  /// exactly. By default, the comparison is case-sensitive, but this can be modified
  /// using the `caseSensitivity` parameter.
  ///
  /// ## Example Usage:
  /// ```dart
  /// final validator = v.string().equals("Hello");
  ///
  /// print(validator.validate("Hello")); // true (exact match)
  /// print(validator.validate("hello")); // false (case-sensitive)
  /// print(validator.validate("Hello ")); // false (extra space)
  /// print(validator.validate(null)); // false
  ///
  /// // Case-insensitive comparison
  /// final validatorIgnoreCase = v.string().equals("Hello", caseSensitivity: CaseSensitivity.insensitive);
  /// print(validatorIgnoreCase.validate("hello")); // true
  /// ```
  ///
  /// [data] The exact string value to compare against.
  ///
  /// [message] *(optional)* Custom error message.
  ///
  /// [caseSensitivity] *(optional)* Determines whether the comparison is case-sensitive (default) or insensitive.
  VString equals(
    String data, {
    String Function(String data)? message,
    CaseSensitivity caseSensitivity = CaseSensitivity.sensitive,
  }) {
    return add(
      EqualsValidator(
        data,
        message: message?.call(data) ?? _message.equals(data),
        caseSensitivity: caseSensitivity,
      ),
    );
  }

  /// Ensures that the string is a valid IP address (IPv4 or IPv6).
  ///
  /// This method validates whether the given string is formatted as a valid IP address.
  /// It supports both IPv4 (e.g., `192.168.1.1`) and IPv6 (e.g., `2001:db8::ff00:42:8329`).
  ///
  /// ## Example Usage:
  /// ```dart
  /// final validator = v.string().ip();
  ///
  /// print(validator.validate("192.168.1.1")); // true (valid IPv4)
  /// print(validator.validate("2001:db8::ff00:42:8329")); // true (valid IPv6)
  /// print(validator.validate("999.999.999.999")); // false (invalid IPv4)
  /// print(validator.validate("invalid-ip")); // false
  /// print(validator.validate(null)); // false
  /// ```
  ///
  /// [message] *(optional)* Custom error message.
  VString ip({String? message}) {
    return add(IPValidator(message: message ?? _message.ip));
  }

  /// Ensures that the string is a valid JSON Web Token (JWT).
  ///
  /// This method validates whether the given string follows the standard JWT format.
  /// A valid JWT consists of three base64-encoded sections separated by dots (`.`):
  /// - Header
  /// - Payload
  /// - Signature
  ///
  /// ## Example Usage:
  /// ```dart
  /// final validator = v.string().jwt();
  ///
  /// print(validator.validate("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvbiIsImlhdCI6MTUxNjIzOTAyMn0.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c")); // true
  /// print(validator.validate("invalid.jwt.token")); // false
  /// print(validator.validate(null)); // false
  /// ```
  ///
  /// [message] *(optional)* Custom error message.
  VString jwt({String? message}) {
    return add(JwtValidator(message: message ?? _message.jwt));
  }

  /// Ensures that the string does not exceed the specified maximum length.
  ///
  /// This method validates that the string contains at most `maxLength` characters.
  /// If the string is longer than the specified length, validation will fail.
  ///
  /// ## Example Usage:
  /// ```dart
  /// final validator = v.string().max(10);
  ///
  /// print(validator.validate("short")); // true
  /// print(validator.validate("this is too long")); // false
  /// print(validator.validate("exactly10!")); // true
  /// ```
  ///
  /// [maxLength] The maximum allowed length of the string.
  ///
  /// [message] *(optional)* Custom error message.
  VString max(int maxLength, {String Function(int maxLength)? message}) {
    return add(
      MaxLengthValidator<String>(
        maxLength,
        message: message?.call(maxLength) ?? _message.max(maxLength),
      ),
    );
  }

  /// Ensures that the string has at least the specified minimum length.
  ///
  /// This method validates that the string contains at least `minLength` characters.
  /// If the string is shorter than the specified length, validation will fail.
  ///
  /// ## Example Usage:
  /// ```dart
  /// final validator = v.string().min(5);
  ///
  /// print(validator.validate("hello")); // true
  /// print(validator.validate("hi")); // false
  /// print(validator.validate("abcdefg")); // true
  /// ```
  ///
  /// - [minLength] The minimum required length of the string.
  ///
  /// - [message] *(optional)* Custom error message.
  VString min(int minLength, {String Function(int minLength)? message}) {
    return add(
      MinLengthValidator<String>(
        minLength,
        message: message?.call(minLength) ?? _message.min(minLength),
      ),
    );
  }

  /// Ensures that the string meets password security requirements.
  ///
  /// This method validates that a given string meets common password strength
  /// criteria, such as a minimum length, inclusion of uppercase and lowercase letters,
  /// numbers, special characters, and the absence of spaces.
  ///
  /// ## Example Usage:
  /// ```dart
  /// final validator = v.string().password();
  ///
  /// print(validator.validate("StrongP@ssword123")); // true
  /// print(validator.validate("StrongP@s sword123")); // false
  /// print(validator.validate("weakpass")); // false
  /// print(validator.validate("123456")); // false
  /// print(validator.validate("NoSpecialChar1")); // false
  /// ```
  ///
  /// - [message] *(optional)* Custom error message.
  VString password({String? message}) {
    return add(PasswordValidator(message: message ?? _message.password));
  }

  /// Ensures that the string matches a given regular expression pattern.
  ///
  /// This method allows validation of a string against a custom regex pattern,
  /// ensuring it conforms to a specific format.
  ///
  /// ## Example Usage:
  /// ```dart
  /// final validator = v.string().pattern(r'^\d{3}-\d{3}-\d{4}$');
  ///
  /// print(validator.validate("123-456-7890")); // true
  /// print(validator.validate("1234567890")); // false
  /// print(validator.validate("abc-456-7890")); // false
  /// ```
  ///
  /// - [pattern] A regular expression string defining the expected format.
  ///
  /// - [message] *(optional)* Custom error message.
  VString pattern(String pattern, {String? message}) {
    return add(PatternValidator(pattern, message: message ?? _message.pattern));
  }

  /// Ensures that the string is a valid slug.
  ///
  /// A slug is a URL-friendly identifier that typically consists of lowercase letters,
  /// numbers, hyphens (`-`), and underscores (`_`). It is commonly used in SEO-friendly
  /// URLs and database identifiers.
  ///
  /// ## Example Usage:
  /// ```dart
  /// final validator = v.string().slug();
  ///
  /// print(validator.validate("valid-slug")); // true
  /// print(validator.validate("Invalid Slug!")); // false
  /// print(validator.validate("slug@123")); // false
  /// ```
  ///
  /// - [message] *(optional)* Custom error message.
  VString slug({String? message}) {
    return add(SlugValidator(message: message ?? _message.uuid));
  }

  /// Ensures that the string starts with a specific prefix.
  ///
  /// This method validates whether the given string begins with the specified `prefix`.
  /// It supports case-sensitive or case-insensitive validation.
  ///
  /// ## Example Usage:
  /// ```dart
  /// final validator = v.string().startsWith("Hello");
  ///
  /// print(validator.validate("Hello World")); // true
  /// print(validator.validate("hello world")); // false (case-sensitive)
  /// print(validator.validate("World Hello")); // false
  /// ```
  ///
  /// ### Case-Insensitive Example:
  /// ```dart
  /// final validator = v.string().startsWith(
  ///   "Hello",
  ///   caseSensitivity: CaseSensitivity.insensitive,
  /// );
  ///
  /// print(validator.validate("hello world")); // true
  /// print(validator.validate("HELLO WORLD")); // true
  /// print(validator.validate("world hello")); // false
  /// ```
  ///
  /// - [prefix] The prefix that the string must start with.
  ///
  /// - [message] *(optional)* Custom error message. If provided as a function,
  /// it receives the `prefix` as a parameter.
  ///
  /// - [caseSensitivity] Defines whether the validation should be case-sensitive or case-insensitive (default: `CaseSensitivity.sensitive`)
  VString startsWith(
    String prefix, {
    String Function(String prefix)? message,
    CaseSensitivity caseSensitivity = CaseSensitivity.sensitive,
  }) {
    return add(
      StartsWithValidator(
        prefix,
        message: message?.call(prefix) ?? _message.startsWith(prefix),
        caseSensitivity: caseSensitivity,
      ),
    );
  }

  /// Ensures that the string follows a valid phone number format for a specified country.
  ///
  /// This method validates whether the given string represents a valid phone number
  /// according to the selected `PhoneType`. It supports different configurations such as:
  /// - Required or optional area codes.
  /// - Required, optional, or no country codes.
  ///
  /// ## Example Usage:
  /// ```dart
  /// final validator = v.string().phone(PhoneType.brazil);
  ///
  /// print(validator.validate("(11) 98765-4321")); // true (valid Brazilian phone)
  /// print(validator.validate("98765-4321")); // false (area code required)
  /// print(validator.validate("invalid-phone")); // false
  /// ```
  ///
  /// ### Custom Configurations:
  /// ```dart
  /// // Validates a U.S. phone number with area code required and no country code.
  /// final validator = v.string().phone(
  ///   PhoneType.usa,
  ///   areaCode: AreaCodeFormat.required,
  ///   countryCode: CountryCodeFormat.none,
  /// );
  ///
  /// print(validator.validate("(123) 456-7890")); // true
  /// print(validator.validate("123-456-7890")); // true
  /// print(validator.validate("456-7890")); // false (area code missing)
  /// ```
  ///
  /// - [type] The `PhoneType` specifying the country format for validation.
  ///
  /// - [message] *(optional)* Custom error message.
  ///
  /// - [areaCode] Defines whether the area code is required, optional, or not allowed. (default: `AreaCodeFormat.required`)
  ///
  /// - [countryCode] Defines whether the country code is required, optional, or not allowed. (default: `CountryCodeFormat.none`)
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

  /// Ensures that the string follows a valid time format.
  ///
  /// This method validates whether the given string represents a valid time format,
  /// typically in `HH:mm` or `HH:mm:ss` format, ensuring correct hour and minute values.
  ///
  /// ## Example Usage:
  /// ```dart
  /// final validator = v.string().time();
  ///
  /// print(validator.validate("14:30")); // true
  /// print(validator.validate("23:59")); // true
  /// print(validator.validate("25:00")); // false (invalid hour)
  /// print(validator.validate("12:61")); // false (invalid minute)
  /// print(validator.validate("invalid-time")); // false
  /// print(validator.validate(null)); // false (required by default)
  /// ```
  ///
  /// [message] Custom error message.
  VString time({String? message}) {
    return add(TimeValidator(message: message ?? _message.time));
  }

  /// Ensures that the string is a valid URL.
  ///
  /// This method validates whether the given string follows a valid URL format,
  /// including both HTTP and HTTPS protocols, as well as domain names.
  ///
  /// ## Example Usage:
  /// ```dart
  /// final validator = v.string().url();
  ///
  /// print(validator.validate("https://example.com")); // true
  /// print(validator.validate("http://example.com")); // true
  /// print(validator.validate("www.example.com")); // false (missing protocol)
  /// print(validator.validate("invalid-url")); // false
  /// print(validator.validate(null)); // false (required by default)
  /// ```
  ///
  /// - [message] Custom error message.
  VString url({String? message}) {
    return add(UrlValidator(message: message ?? _message.url));
  }

  /// Ensures that the string is a valid UUID (Universally Unique Identifier).
  ///
  /// This method validates whether the given string conforms to the specified UUID version.
  /// By default, it validates against UUID v4, but other versions can be specified.
  ///
  /// ## Example Usage:
  /// ```dart
  /// final validator = v.string().uuid();
  ///
  /// print(validator.validate("550e8400-e29b-41d4-a716-446655440000")); // true (valid UUID v4)
  /// print(validator.validate("550e8400-e29b-31d4-a716-446655440000")); // false (not a valid UUID v4)
  /// print(validator.validate("invalid-uuid")); // false
  /// print(validator.validate(null)); // false (required by default)
  ///
  /// // Specifying a UUID version
  /// final uuidV1Validator = v.string().uuid(version: UUIDVersion.v1);
  /// print(uuidV1Validator.validate("550e8400-e29b-11d4-a716-446655440000")); // true (valid UUID v1)
  /// ```
  ///
  /// - [version] *(optional)* The UUID version to validate against (default: `UUIDVersion.v4`).
  ///
  /// - [message] *(optional)* Custom error message.
  VString uuid({UUIDVersion? version, String? message}) {
    return add(
      UUIDValidator(
        message: message ?? _message.uuid,
        version: version ?? UUIDVersion.v4,
      ),
    );
  }

  /// Adds a custom validator to the `VString` instance.
  ///
  /// This method allows for the addition of a custom validation rule to the string validator,
  /// enabling more flexible and specific validation logic.
  ///
  /// Example usage:
  /// ```dart
  /// final validator = v.string().add(MyCustomValidator());
  ///
  /// print(validator.validate("custom value")); // Depends on MyCustomValidator logic
  /// ```
  ///
  /// - [validator] The custom validator to be applied.
  @override
  VString add(Validator<String> validator) {
    super.add(validator);
    return this;
  }

  /// Ensures that the string passes at least one of the specified validation rules.
  ///
  /// This method allows combining multiple `VString` validators. The input value
  /// must satisfy at least one validation rule provided in the `types` list.
  ///
  /// ## Example Usage:
  /// ```dart
  /// final validator = v.string().any([
  ///   v.string().equals("hello"),
  ///   v.string().equals("world"),
  /// ]);
  ///
  /// print(validator.validate("hello")); // true (matches the first rule)
  /// print(validator.validate("world")); // true (matches the second rule)
  /// print(validator.validate("hello world")); // false (does not match any rule)
  /// print(validator.validate("random text")); // false (does not match any rule)
  /// print(validator.validate(null)); // false (required by default)
  /// ```
  ///
  /// - [types] A list of `VString` validators. The input must satisfy at least one of them.
  ///
  /// - [message] *(optional)* Custom error message.
  @override
  VString any(covariant List<VString> types, {String? message}) {
    super.any(types, message: message ?? _message.any);
    return this;
  }

  /// Converts the current string validator into an array validator.
  ///
  /// This method wraps the current string validation rules into a `VArray<String>`,
  /// allowing validation of lists of strings. Each item in the array will be validated
  /// against the current string validation rules.
  ///
  /// ## Example Usage:
  /// ```dart
  /// final validator = v.string().min(3).max(10).array();
  ///
  /// print(validator.validate(["hello", "world"])); // true
  /// print(validator.validate(["hi", "longwordexceeds"])); // false
  /// ```
  ///
  /// - [message] *(optional)* Optional custom error message for the array validation.
  @override
  VArray<String> array({String? message}) {
    return VArray<String>(this, _message.array, message: message);
  }

  /// Ensures that the string passes all the specified validation rules.
  ///
  /// This method allows combining multiple `VString` validators. The input value
  /// must satisfy every validation rule provided in the `types` list.
  ///
  /// ## Example Usage:
  /// ```dart
  /// final validator = v.string().every([
  ///   v.string().min(5),
  ///   v.string().max(10),
  ///   v.string().contains("test"),
  /// ]);
  ///
  /// print(validator.validate("test123")); // true (meets all conditions)
  /// print(validator.validate("test12")); // true
  /// print(validator.validate("short")); // false (does not meet min length)
  /// print(validator.validate("this is a long test")); // false (exceeds max length)
  /// print(validator.validate("randomword")); // false (does not contain "test")
  /// print(validator.validate(null)); // false (required by default)
  /// ```
  ///
  /// - [types] A list of `VString` validators that the input must satisfy.
  ///
  /// - [message] *(optional)* Custom error message.
  @override
  VString every(covariant List<VString> types, {String? message}) {
    super.every(types, message: message ?? _message.every);
    return this;
  }

  /// Marks the string validator as nullable.
  ///
  /// When a validator is marked as nullable, it allows `null` values to pass validation
  /// without triggering an error. Other validation rules will still be applied if a non-null
  /// value is provided.
  ///
  /// ## Example Usage:
  /// ```dart
  /// final validator = v.string().min(3).nullable();
  ///
  /// print(validator.validate(null)); // true (null is allowed)
  /// print(validator.validate("hi")); // false (does not meet min length requirement)
  /// print(validator.validate("hello")); // true
  /// ```
  @override
  VString nullable() {
    super.nullable();
    return this;
  }

  /// Marks the string validator as optional.
  ///
  /// When a validator is marked as optional, it allows `null` or empty values (`""`)
  /// to pass validation without triggering an error. Other validation rules will still
  /// be applied if a non-empty value is provided.
  ///
  /// ## Example Usage:
  /// ```dart
  /// final validator = v.string().min(3).optional();
  ///
  /// print(validator.validate(null)); // true (null is allowed)
  /// print(validator.validate("")); // true (empty string is allowed)
  /// print(validator.validate("hi")); // false (does not meet min length requirement)
  /// print(validator.validate("hello")); // true
  /// ```
  @override
  VString optional() {
    super.optional();
    return this;
  }

  /// Applies a custom validation rule using a refine function.
  ///
  /// This method allows defining a custom validation logic using the provided `validator` function.
  /// The function receives the input string and should return `true` if the validation passes,
  /// or `false` if it fails. If the validation fails, the optional `message` parameter can be used
  /// to provide a custom error message.
  ///
  /// Example usage:
  /// ```dart
  /// final validator = v.string().refine(
  ///   (value) => value.length > 5,
  ///   message: "The string must have more than 5 characters",
  /// );
  ///
  /// print(validator.validate("Hello")); // false
  /// print(validator.validate("Hello World")); // true
  /// ```
  ///
  /// - [validator] A function that returns `true` if the validation passes, or `false` otherwise.
  /// - [message] *(optional)* Custom error message.
  @override
  VString refine(bool Function(String data) validator, {String? message}) {
    super.refine(validator, message: message ?? _message.refine);
    return this;
  }
}
