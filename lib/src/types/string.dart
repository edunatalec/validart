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
import 'package:validart/src/validators/max_length_validator.dart';
import 'package:validart/src/validators/min_length_validator.dart';
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
/// ### Example
/// ```dart
/// final validator = v.string().email();
/// print(validator.validate('test@example.com')); // true
/// print(validator.validate('invalid-email')); // false
/// ```
class VString extends VPrimitive<String> {
  final StringMessage _message;

  /// Creates an instance of `VString` for validating string values.
  ///
  /// This constructor initializes the string validator and automatically applies a `RequiredValidator`
  /// to ensure that the string is not empty unless explicitly marked as optional.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.string().min(5);
  ///
  /// print(validator.validate("hello")); // true
  /// print(validator.validate("hi")); // 'String must be at least 5 characters long' (invalid)
  /// ```
  ///
  /// ### Parameters
  /// - [_message]: The validation messages used for error handling.
  /// - [message]: *(optional)* A custom error message for required validation.
  ///
  /// ### Behavior
  /// - By default, this validator ensures that the string is required (not empty or null).
  /// - To allow empty or missing values, use `.optional()` or `.nullable()`.
  VString(this._message, {required String? message}) {
    add(RequiredValidator(message: message ?? _message.required));
  }

  /// Ensures that the string contains only alphabetic characters (`A-Z`, `a-z`).
  ///
  /// This method adds an `AlphaValidator` to check if the string consists solely of letters,
  /// without any numbers, spaces, or special characters.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.string().alpha();
  ///
  /// print(validator.validate("ValidString")); // true
  /// print(validator.validate("1234")); // 'String must contain only alphabetic characters' (invalid)
  /// print(validator.validate("Hello123")); // 'String must contain only alphabetic characters' (invalid)
  /// ```
  ///
  /// ### Parameters
  /// - [message]: *(optional)* A custom validation message.
  ///
  /// ### Returns
  /// The current `VString` instance with the `alpha` validation applied.
  VString alpha({String? message}) {
    return add(AlphaValidator(message: message ?? _message.alpha));
  }

  /// Ensures that the string contains only alphanumeric characters (letters and numbers).
  ///
  /// This method adds an `AlphanumericValidator` to check if the given string consists only of letters (A-Z, a-z)
  /// and numbers (0-9), without any symbols or spaces.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.string().card();
  ///
  /// print(validator.validate("4111111111111111")); // true (Valid Visa card)
  /// print(validator.validate("1234567812345678")); // false
  /// print(validator.validate("4111-1111-1111-1111")); // true (formatted correctly)
  /// print(validator.validate(null)); // false
  /// ```
  ///
  /// ### Parameters
  /// - [message]: *(optional)* A custom validation message.
  ///
  /// ### Returns
  /// The current `VString` instance with the `alphanumeric` validation applied.
  VString alphanumeric({String? message}) {
    return add(
      AlphanumericValidator(message: message ?? _message.alphanumeric),
    );
  }

  /// Ensures that the string is a valid credit card number.
  ///
  /// This method adds an `CardValidator` to check if the given string follows the standard
  /// credit card number format, checking for the correct length and structure.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.string().card();
  ///
  /// print(validator.validate("4111111111111111")); // true (Valid Visa card)
  /// print(validator.validate("1234567812345678")); // false
  /// print(validator.validate("4111-1111-1111-1111")); // true (formatted correctly)
  /// print(validator.validate(null)); // false
  /// ```
  ///
  /// ### Parameters
  /// - [message]: *(optional)* A custom validation message.
  ///
  /// ### Returns
  /// The current `VString` instance with the `card` validation applied.
  VString card({String? message}) {
    return add(CardValidator(message: message ?? _message.card));
  }

  /// Ensures that the string is a valid Brazilian postal code (CEP).
  ///
  /// This method adds an `CEPValidator` to check if the given string follows the correct CEP format,
  /// which is either `XXXXX-XXX` or `XXXXXXXX`, where `X` represents a digit.
  ///
  /// ### Example
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
  /// ### Parameters
  /// - [message]: *(optional)* A custom validation message.
  ///
  /// ### Returns
  /// The current `VString` instance with the `cep` validation applied.
  VString cep({String? message}) {
    return add(CEPValidator(message: message ?? _message.cep));
  }

  /// Ensures that the string is a valid CNPJ (Cadastro Nacional da Pessoa Jurídica).
  ///
  /// This method adds an `CEPValidator` to check if the given string is a properly formatted and valid CNPJ,
  /// which is the Brazilian national registry number for legal entities.
  ///
  /// ### Example
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
  /// ### Parameters
  /// - [message]: *(optional)* A custom validation message.
  ///
  /// ### Returns
  /// The current `VString` instance with the `cnpj` validation applied.
  VString cnpj({String? message}) {
    return add(CNPJValidator(message: message ?? _message.cnpj));
  }

  /// Ensures that the string contains the specified substring.
  ///
  /// This method adds a `ContainsValidator` to check if the given string includes the provided `data` as a substring.
  /// By default, the validation is case-sensitive, but this behavior can be modified using the `caseSensitivity` parameter.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.string().contains("hello");
  ///
  /// print(validator.validate("hello world")); // true
  /// print(validator.validate("Hello World")); // false (case-sensitive)
  /// print(validator.validate("world")); // false
  ///
  /// // Case-insensitive comparison
  /// final validatorIgnoreCase = v.string().contains("hello", caseSensitivity: CaseSensitivity.insensitive);
  /// print(validatorIgnoreCase.validate("Hello World")); // true
  /// ```
  ///
  /// ### Parameters
  /// - [data]: The expected substring that must be present in the string.
  /// - [message] *(optional)*: A custom error message function that takes `data` as input.
  /// - [caseSensitivity]: Defines whether the validation should be case-sensitive (default: `CaseSensitivity.sensitive`).
  ///
  /// ### Returns
  /// The current `VString` instance with the `contains` validation applied.
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
  /// This method adds an `CPFValidator` to check if the provided string follows the CPF format,
  /// which is a Brazilian individual taxpayer registry number.
  ///
  /// ### Example
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
  /// ### Parameters
  /// - [message]: *(optional)* A custom validation message.
  ///
  /// ### Returns
  /// The current `VString` instance with the `cpf` validation applied.
  VString cpf({String? message}) {
    return add(CPFValidator(message: message ?? _message.cpf));
  }

  /// Ensures that the string is a valid date format.
  ///
  /// This method adds an `DateValidator` to check if the given string conforms to a valid date format.
  ///
  /// ### Example
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
  /// ### Parameters
  /// - [message]: *(optional)* A custom validation message.
  ///
  /// ### Returns
  /// The current `VString` instance with the `date` validation applied.
  VString date({String? message}) {
    return add(DateValidator(message: message ?? _message.date));
  }

  /// Validates that the string is a properly formatted email address.
  ///
  /// This method adds an `EmailValidator` to check if the string follows the standard email format.
  /// It checks for the presence of an "@" symbol, a valid domain, and a top-level domain.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.string().email();
  ///
  /// print(validator.validate('test@example.com')); // true
  /// print(validator.validate('invalid-email')); // false
  /// print(validator.validate('user@domain')); // false
  /// print(validator.validate('user@.com')); // false
  /// ```
  ///
  /// ### Parameters
  /// - [message]: *(optional)* A custom validation message.
  ///
  /// ### Returns
  /// The current `VString` instance with the `email` validation applied.
  VString email({String? message}) {
    return add(EmailValidator(message: message ?? _message.email));
  }

  /// Ensures that the string ends with the specified suffix.
  ///
  /// This method adds an `EndsWithValidator` to verify whether the given string concludes with the provided `sufix`.
  /// By default, the validation is case-sensitive, but this behavior can be modified using the `caseSensitivity` parameter.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.string().endsWith("world");
  ///
  /// print(validator.validate("hello world")); // true
  /// print(validator.validate("Hello World")); // false (case-sensitive)
  /// print(validator.validate("hello")); // false
  ///
  /// // Case-insensitive comparison
  /// final validatorIgnoreCase = v.string().endsWith("world", caseSensitivity: CaseSensitivity.insensitive);
  /// print(validatorIgnoreCase.validate("Hello World")); // true
  /// ```
  ///
  /// ### Parameters
  /// - [sufix]: The expected suffix that the string must end with.
  /// - [message] *(optional)*: A custom error message function that takes `sufix` as input.
  /// - [caseSensitivity]: Defines whether the validation should be case-sensitive (default: `CaseSensitivity.sensitive`).
  ///
  /// ### Returns
  /// The current `VString` instance with the `endsWith` validation applied.
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
  /// This method adds an `EqualsValidator` to check if the given string matches the provided `data` exactly.
  /// By default, the validation is case-sensitive, but this behavior can be modified using the `caseSensitivity` parameter.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.string().equals("hello");
  ///
  /// print(validator.validate("hello")); // true
  /// print(validator.validate("Hello")); // false (case-sensitive)
  /// print(validator.validate("hello world")); // false
  ///
  /// // Case-insensitive comparison
  /// final validatorIgnoreCase = v.string().equals("hello", caseSensitivity: CaseSensitivity.insensitive);
  /// print(validatorIgnoreCase.validate("Hello")); // true
  /// ```
  ///
  /// ### Parameters
  /// - [data]: The exact string that must match the input.
  /// - [message] *(optional)*: A custom error message function that takes `data` as input.
  /// - [caseSensitivity]: Defines whether the validation should be case-sensitive (default: `CaseSensitivity.sensitive`).
  ///
  /// ### Returns
  /// The current `VString` instance with the `equals` validation applied.
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
  /// This method adds an `IPValidator` to check if the given string is formatted as a valid IP address.
  /// It supports both IPv4 (e.g., `192.168.1.1`) and IPv6 (e.g., `2001:db8::ff00:42:8329`).
  ///
  /// ### Example
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
  /// ### Parameters
  /// - [message]: *(optional)* A custom validation message.
  ///
  /// ### Returns
  /// The current `VString` instance with the `email` validation applied.
  VString ip({String? message}) {
    return add(IPValidator(message: message ?? _message.ip));
  }

  /// Ensures that the string is a valid JSON Web Token (JWT).
  ///
  /// This method adds an `JwtValidator` to check if the given string follows the standard JWT format.
  /// A valid JWT consists of three base64-encoded sections separated by dots (`.`):
  /// - Header
  /// - Payload
  /// - Signature
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.string().jwt();
  ///
  /// print(validator.validate("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvbiIsImlhdCI6MTUxNjIzOTAyMn0.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c")); // true
  /// print(validator.validate("invalid.jwt.token")); // false
  /// print(validator.validate(null)); // false
  /// ```
  ///
  /// ### Parameters
  /// - [message]: *(optional)* A custom validation message.
  ///
  /// ### Returns
  /// The current `VString` instance with the `email` validation applied.
  VString jwt({String? message}) {
    return add(JwtValidator(message: message ?? _message.jwt));
  }

  /// Ensures that the string does not exceed the specified maximum length.
  ///
  /// This method adds a `MaxLengthValidator` to verify that the given string has at most `maxLength` characters.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.string().max(5);
  ///
  /// print(validator.validate("hello")); // true
  /// print(validator.validate("world!")); // false (exceeds 5 characters)
  /// print(validator.validate("hi")); // true
  /// ```
  ///
  /// ### Parameters
  /// - [maxLength]: The maximum number of characters allowed in the string.
  /// - [message] *(optional)*: A custom error message function that takes `maxLength` as input.
  ///
  /// ### Returns
  /// The current `VString` instance with the `max` validation applied.
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
  /// This method adds a `MinLengthValidator` to verify that the given string contains at least `minLength` characters.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.string().min(3);
  ///
  /// print(validator.validate("hi")); // false (less than 3 characters)
  /// print(validator.validate("hey")); // true
  /// print(validator.validate("hello")); // true
  /// ```
  ///
  /// ### Parameters
  /// - [minLength]: The minimum number of characters required in the string.
  /// - [message] *(optional)*: A custom error message function that takes `minLength` as input.
  ///
  /// ### Returns
  /// The current `VString` instance with the `min` validation applied.
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
  /// This method adds an `PasswordValidator` to check if the given string meets common password strength
  /// criteria, such as a minimum length, inclusion of uppercase and lowercase letters,
  /// numbers, special characters, and the absence of spaces.
  ///
  /// ### Example
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
  /// ### Parameters
  /// - [message]: *(optional)* A custom validation message.
  ///
  /// ### Returns
  /// The current `VString` instance with the `email` validation applied.
  VString password({String? message}) {
    return add(PasswordValidator(message: message ?? _message.password));
  }

  /// Ensures that the string matches the specified regular expression pattern.
  ///
  /// This method adds a `PatternValidator` to verify that the given string conforms to the provided `pattern`.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.string().pattern(r'^[a-zA-Z]+$');
  ///
  /// print(validator.validate("hello")); // true (only letters)
  /// print(validator.validate("Hello123")); // false (contains numbers)
  /// print(validator.validate("!@#")); // false (contains special characters)
  ///
  /// // Custom error message
  /// final validatorWithMessage = v.string().pattern(r'^[0-9]+$', message: "Only numbers are allowed.");
  /// print(validatorWithMessage.validate("123")); // true
  /// print(validatorWithMessage.validate("abc")); // false (returns "Only numbers are allowed.")
  /// ```
  ///
  /// ### Parameters
  /// - [pattern]: A regular expression string defining the allowed format.
  /// - [message] *(optional)*: A custom error message displayed when the validation fails.
  ///
  /// ### Returns
  /// The current `VString` instance with the `pattern` validation applied.
  VString pattern(String pattern, {String? message}) {
    return add(PatternValidator(pattern, message: message ?? _message.pattern));
  }

  /// Ensures that the string is a valid slug.
  ///
  /// This method adds an `SlugValidator` to check if the provided string is a URL-friendly identifier that typically consists of lowercase letters,
  /// numbers, hyphens (`-`), and underscores (`_`). It is commonly used in SEO-friendly
  /// URLs and database identifiers.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.string().slug();
  ///
  /// print(validator.validate("valid-slug")); // true
  /// print(validator.validate("Invalid Slug!")); // false
  /// print(validator.validate("slug@123")); // false
  /// ```
  ///
  /// ### Parameters
  /// - [message]: *(optional)* A custom validation message.
  ///
  /// ### Returns
  /// The current `VString` instance with the `email` validation applied.
  VString slug({String? message}) {
    return add(SlugValidator(message: message ?? _message.uuid));
  }

  /// Ensures that the string starts with the specified prefix.
  ///
  /// This method adds a `StartsWithValidator` to verify whether the given string begins with the provided `prefix`.
  /// By default, the validation is case-sensitive, but this behavior can be modified using the `caseSensitivity` parameter.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.string().startsWith("hello");
  ///
  /// print(validator.validate("hello world")); // true
  /// print(validator.validate("Hello World")); // false (case-sensitive)
  /// print(validator.validate("world hello")); // false
  ///
  /// // Case-insensitive comparison
  /// final validatorIgnoreCase = v.string().startsWith("hello", caseSensitivity: CaseSensitivity.insensitive);
  /// print(validatorIgnoreCase.validate("Hello World")); // true
  /// ```
  ///
  /// ### Parameters
  /// - [prefix]: The expected prefix that the string must start with.
  /// - [message] *(optional)*: A custom error message function that takes `prefix` as input.
  /// - [caseSensitivity]: Defines whether the validation should be case-sensitive (default: `CaseSensitivity.sensitive`).
  ///
  /// ### Returns
  /// The current `VString` instance with the `startsWith` validation applied.
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

  /// Ensures that the string is a valid phone number based on the specified format.
  ///
  /// This method adds a `PhoneValidator` to verify whether the given string matches a valid phone number format,
  /// considering the `type`, `areaCode`, and `countryCode` options.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.string().phone(PhoneType.brazil);
  ///
  /// print(validator.validate("(11) 98765-4321")); // true (valid mobile number)
  /// print(validator.validate("12345")); // false (too short)
  /// print(validator.validate("abcd1234")); // false (contains letters)
  /// ```
  ///
  /// ### Parameters
  /// - [type]: The type of phone number to validate (e.g., mobile, landline).
  /// - [message] *(optional)*: A custom error message displayed when validation fails.
  /// - [areaCode]: Defines whether the area code is required, optional, or not allowed (default: `AreaCodeFormat.required`).
  /// - [countryCode]: Defines whether the country code is required, optional, or not allowed (default: `CountryCodeFormat.none`).
  ///
  /// ### Returns
  /// The current `VString` instance with the `phone` validation applied.
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
  /// This method adds an `TimeValidator` to check if the given string represents a valid time format,
  /// typically in `HH:mm` or `HH:mm:ss` format, ensuring correct hour and minute values.
  ///
  /// ### Example
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
  /// ### Parameters
  /// - [message]: *(optional)* A custom validation message.
  ///
  /// ### Returns
  /// The current `VString` instance with the `email` validation applied.
  VString time({String? message}) {
    return add(TimeValidator(message: message ?? _message.time));
  }

  /// Ensures that the string is a valid URL.
  ///
  /// This method adds an `TimeValidator` to check if the given string follows a valid URL format,
  /// including both HTTP and HTTPS protocols, as well as domain names.
  ///
  /// ### Example
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
  /// ### Parameters
  /// - [message]: *(optional)* A custom validation message.
  ///
  /// ### Returns
  /// The current `VString` instance with the `email` validation applied.
  VString url({String? message}) {
    return add(UrlValidator(message: message ?? _message.url));
  }

  /// Ensures that the string is a valid UUID (Universally Unique Identifier).
  ///
  /// This method adds a `UUIDValidator` to check if the given string conforms to a valid UUID format.
  /// By default, it validates against UUID version 4, but a different version can be specified using the `version` parameter.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.string().uuid();
  ///
  /// print(validator.validate("550e8400-e29b-41d4-a716-446655440000")); // true (valid UUID v4)
  /// print(validator.validate("invalid-uuid")); // false
  ///
  /// // Validating a specific UUID version
  /// final validatorV1 = v.string().uuid(version: UUIDVersion.v1);
  /// print(validatorV1.validate("6ba7b810-9dad-11d1-80b4-00c04fd430c8")); // true (valid UUID v1)
  /// ```
  ///
  /// ### Parameters
  /// - [version] *(optional)*: The UUID version to validate against (default: `UUIDVersion.v4`).
  /// - [message] *(optional)*: A custom error message displayed when validation fails.
  ///
  /// ### Returns
  /// The current `VString` instance with the `uuid` validation applied.
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
  /// This method allows adding additional validation rules for string values,
  /// enabling more flexible and specific constraints.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.string().add(MyCustomStringValidator());
  ///
  /// print(validator.validate("custom input")); // Validation depends on custom logic
  /// ```
  ///
  /// ### Parameters
  /// - [validator]: A custom validator that extends `Validator<String>`.
  ///
  /// ### Returns
  /// The current `VString` instance with the added validator.
  @override
  VString add(Validator<String> validator) {
    super.add(validator);
    return this;
  }

  /// Ensures that the string matches **at least one** of the provided `VString` validators.
  ///
  /// This method checks if the string satisfies at least one of the specified validation rules.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.string().any([
  ///   v.string().max(5),
  ///   v.string().pattern(r'^[a-z]+$')
  /// ]);
  ///
  /// print(validator.validate("hello")); // true (passes "max" validation)
  /// print(validator.validate("abcdef")); // true (passes "pattern" validation)
  /// print(validator.validate("123456")); // false (matches neither condition)
  /// ```
  ///
  /// ### Parameters
  /// - [types]: A list of `VString` validators to check against.
  /// - [message] *(optional)*: A custom validation message if the value does not match any validator.
  ///
  /// ### Returns
  /// The current `VString` instance with the `any` validation applied.
  @override
  VString any(covariant List<VString> types, {String? message}) {
    super.any(types, message: message ?? _message.any);
    return this;
  }

  /// Creates an array validator (`VArray<String>`) for validating lists of string values.
  ///
  /// This method enables validation of arrays where each element is a `String`,
  /// applying the same validation rules defined for the individual string validator.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.string().array();
  ///
  /// print(validator.validate(["hello", "world"])); // true (valid)
  ///
  /// print(validator.validate(["hello", 123])); // false (invalid)
  /// ```
  ///
  /// ### Parameters
  /// - [message] *(optional)*: A custom validation message for array validation errors.
  ///
  /// ### Returns
  /// A `VArray<String>` instance for validating lists of string values.
  @override
  VArray<String> array({String? message}) {
    return VArray<String>(this, _message.array, message: message);
  }

  /// Ensures that the string matches **all** of the provided `VString` validators.
  ///
  /// This method checks if the string satisfies every specified validation rule.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.string().every([
  ///   v.string().min(3),
  ///   v.string().max(10)
  /// ]);
  ///
  /// print(validator.validate("hello")); // true (passes both conditions)
  /// print(validator.validate("hi")); // false (fails "min" validation)
  /// print(validator.validate("this is too long")); // false (fails "max" validation)
  /// ```
  ///
  /// ### Parameters
  /// - [types]: A list of `VString` validators to check against.
  /// - [message] *(optional)*: A custom validation message if the value does not match all validators.
  ///
  /// ### Returns
  /// The current `VString` instance with the `every` validation applied.
  @override
  VString every(covariant List<VString> types, {String? message}) {
    super.every(types, message: message ?? _message.every);
    return this;
  }

  /// Marks the string as nullable, allowing `null` as a valid value.
  ///
  /// When this method is applied, the validation will pass if the value is `null`,
  /// otherwise, all other validation rules will be checked.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.string().nullable();
  ///
  /// print(validator.validate(null)); // true (valid)
  /// print(validator.validate("hello")); // true (valid)
  /// ```
  ///
  /// ### Returns
  /// The current `VString` instance with the `nullable` flag enabled.
  @override
  VString nullable() {
    super.nullable();
    return this;
  }

  /// Marks the string as optional, meaning it does not require a value.
  ///
  /// When this method is applied, an empty string will pass validation, while
  /// other validation rules will still apply if a value is provided.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.string().optional();
  ///
  /// print(validator.validate("")); // true (valid)
  /// print(validator.validate("hello")); // true (valid)
  /// ```
  ///
  /// ### Returns
  /// The current `VString` instance with the `optional` flag enabled.
  @override
  VString optional() {
    super.optional();
    return this;
  }

  /// Applies a custom validation function to the `String` value.
  ///
  /// This method allows defining a custom validation rule using a function
  /// that evaluates the `String` value and returns `true` if valid.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.string().refine(
  ///   (value) => value.contains("valid"),
  ///   message: "String must contain 'valid'",
  /// );
  ///
  /// print(validator.validate("this is valid")); // true (valid)
  /// print(validator.validate("invalid input")); // false (invalid)
  /// ```
  ///
  /// ### Parameters
  /// - [validator]: A function that takes a `String` and returns `true` if valid.
  /// - [message] *(optional)*: A custom validation message.
  ///
  /// ### Returns
  /// The current `VString` instance with the custom validation applied.
  @override
  VString refine(bool Function(String data) validator, {String? message}) {
    super.refine(validator, message: message ?? _message.refine);
    return this;
  }
}
