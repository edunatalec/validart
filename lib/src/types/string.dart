part of 'type.dart';

/// Validates [String] values.
///
/// ```dart
/// final schema = V.string().email().min(5);
/// schema.parse('user@mail.com'); // 'user@mail.com'
/// ```
class VString extends VType<String> {
  @override
  VString add(
    Validator<String> validator, {
    String? message,
    List<Object>? path,
  }) {
    super.add(validator, message: message, path: path);
    return this;
  }

  @override
  VString nullable() {
    super.nullable();
    return this;
  }

  @override
  VString defaultValue(String value) {
    super.defaultValue(value);
    return this;
  }

  @override
  VString preprocess(Object? Function(Object? value) fn) {
    super.preprocess(fn);
    return this;
  }

  @override
  VString refine(
    bool Function(String value) check, {
    String? message,
    String? code,
  }) {
    super.refine(check, message: message, code: code);
    return this;
  }

  /// Validates that the string is not empty.
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.string().notEmpty().parse('hello'); // 'hello'
  /// V.string().notEmpty().validate('');   // false
  /// ```
  VString notEmpty({String? message}) {
    add(const NotEmptyValidator(), message: message);
    return this;
  }

  /// Validates that the string has at least [length] characters.
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.string().min(3).validate('abc');  // true
  /// V.string().min(3).validate('ab');   // false
  /// ```
  VString min(int length, {String Function(int)? message}) {
    add(MinLengthValidator(min: length), message: message?.call(length));
    return this;
  }

  /// Validates that the string has at most [length] characters.
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.string().max(5).validate('hello');  // true
  /// V.string().max(5).validate('toolong'); // false
  /// ```
  VString max(int length, {String Function(int)? message}) {
    add(MaxLengthValidator(max: length), message: message?.call(length));
    return this;
  }

  /// Validates that the string has exactly [len] characters.
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.string().length(4).validate('test');  // true
  /// V.string().length(4).validate('no');    // false
  /// ```
  VString length(int len, {String Function(int)? message}) {
    add(LengthValidator(length: len), message: message?.call(len));
    return this;
  }

  /// Validates that the string is a valid email address.
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.string().email().validate('user@mail.com'); // true
  /// V.string().email().validate('invalid');        // false
  /// ```
  VString email({String? message}) {
    add(const EmailValidator(), message: message);
    return this;
  }

  /// Validates that the string is a valid URL.
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.string().url().validate('https://example.com'); // true
  /// V.string().url().validate('not-a-url');            // false
  /// ```
  VString url({String? message}) {
    add(const UrlValidator(), message: message);
    return this;
  }

  /// Validates that the string is a valid UUID.
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.string().uuid().validate('550e8400-e29b-41d4-a716-446655440000'); // true
  /// ```
  VString uuid({String? message}) {
    add(const UuidValidator(), message: message);
    return this;
  }

  /// Validates that the string is a valid IP address.
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.string().ip().validate('192.168.1.1'); // true
  /// V.string().ip().validate('999.0.0.1');   // false
  /// ```
  VString ip({String? message}) {
    add(const IpValidator(), message: message);
    return this;
  }

  /// Validates that the string matches the given [regex] pattern.
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.string().pattern(r'^\d{3}$').validate('123'); // true
  /// V.string().pattern(r'^\d{3}$').validate('abc'); // false
  /// ```
  VString pattern(String regex, {String? message}) {
    add(PatternValidator(pattern: regex), message: message);
    return this;
  }

  /// Validates that the string is a valid date in ISO 8601 format.
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.string().date().validate('2024-01-15'); // true
  /// V.string().date().validate('not-a-date'); // false
  /// ```
  VString date({String? message}) {
    add(const DateStringValidator(), message: message);
    return this;
  }

  /// Validates that the string is a valid time in `HH:mm` or `HH:mm:ss`
  /// format.
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.string().time().validate('14:30');    // true
  /// V.string().time().validate('25:00');    // false
  /// ```
  VString time({String? message}) {
    add(const TimeValidator(), message: message);
    return this;
  }

  /// Validates that the string contains [value] as a substring.
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.string().contains('world').validate('hello world'); // true
  /// V.string().contains('xyz').validate('hello');         // false
  /// ```
  VString contains(String value, {String? message}) {
    add(ContainsValidator(substring: value), message: message);
    return this;
  }

  /// Validates that the string starts with [prefix].
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.string().startsWith('http').validate('https://x.com'); // true
  /// V.string().startsWith('http').validate('ftp://x.com');   // false
  /// ```
  VString startsWith(String prefix, {String? message}) {
    add(StartsWithValidator(prefix: prefix), message: message);
    return this;
  }

  /// Validates that the string ends with [suffix].
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.string().endsWith('.dart').validate('main.dart'); // true
  /// V.string().endsWith('.dart').validate('main.js');   // false
  /// ```
  VString endsWith(String suffix, {String? message}) {
    add(EndsWithValidator(suffix: suffix), message: message);
    return this;
  }

  /// Validates that the string is exactly equal to [value].
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.string().equals('yes').validate('yes'); // true
  /// V.string().equals('yes').validate('no');  // false
  /// ```
  VString equals(String value, {String? message}) {
    add(EqualsValidator(expected: value), message: message);
    return this;
  }

  /// Validates that the string contains only letters (a-z, A-Z).
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.string().alpha().validate('hello'); // true
  /// V.string().alpha().validate('abc1');  // false
  /// ```
  VString alpha({String? message}) {
    add(const AlphaValidator(), message: message);
    return this;
  }

  /// Validates that the string contains only letters and numbers.
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.string().alphanumeric().validate('abc123'); // true
  /// V.string().alphanumeric().validate('abc!');   // false
  /// ```
  VString alphanumeric({String? message}) {
    add(const AlphanumericValidator(), message: message);
    return this;
  }

  /// Validates that the string is a valid URL slug.
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.string().slug().validate('my-post-title'); // true
  /// V.string().slug().validate('My Post!');      // false
  /// ```
  VString slug({String? message}) {
    add(const SlugValidator(), message: message);
    return this;
  }

  /// Validates that the string meets password strength requirements.
  ///
  /// Requires at least 8 characters, including uppercase, lowercase, digit,
  /// and special character.
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.string().password().validate('Str0ng!Pass'); // true
  /// V.string().password().validate('weak');         // false
  /// ```
  VString password({String? message}) {
    add(const PasswordValidator(), message: message);
    return this;
  }

  /// Validates that the string is a valid JWT token.
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.string().jwt().validate('eyJhbG.eyJzdW.SflKx'); // true
  /// V.string().jwt().validate('not-a-jwt');            // false
  /// ```
  VString jwt({String? message}) {
    add(const JwtValidator(), message: message);
    return this;
  }

  /// Validates that the string is a valid credit card number.
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.string().card().validate('4111111111111111'); // true
  /// V.string().card().validate('1234');             // false
  /// ```
  VString card({String? message}) {
    add(const CardValidator(), message: message);
    return this;
  }

  /// Validates that the string is a valid phone number.
  ///
  /// Defaults to the E.164 international format via [E164PhonePattern].
  /// Pass a [pattern] to plug in a country-specific rule (for example,
  /// `BrPhonePattern` from `validart_br`).
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.string().phone().validate('+5511999999999'); // true (E.164 default)
  /// V.string().phone(pattern: const MyCountryPhonePattern())
  ///   .validate('(11) 98765-4321');
  /// ```
  VString phone({PhonePattern? pattern, String? message}) {
    add(
      PhoneValidator(pattern: pattern ?? const E164PhonePattern()),
      message: message,
    );
    return this;
  }

  /// Removes leading and trailing whitespace from the value.
  ///
  /// Runs in the pre-processing phase, before any validation. The order in
  /// the chain does not matter — `trim` always runs first.
  ///
  /// ```dart
  /// V.string().trim().email().parse('  user@mail.com  '); // 'user@mail.com'
  /// V.string().email().trim().parse('  user@mail.com  '); // 'user@mail.com'
  /// ```
  VString trim() {
    _preTransform((value) => value.trim());
    return this;
  }

  /// Converts the value to lowercase.
  ///
  /// Runs in the pre-processing phase, before any validation. The order in
  /// the chain does not matter — `toLowerCase` always runs first.
  ///
  /// ```dart
  /// V.string().toLowerCase().equals('hello').parse('HELLO'); // 'hello'
  /// V.string().equals('hello').toLowerCase().parse('HELLO'); // 'hello'
  /// ```
  VString toLowerCase() {
    _preTransform((value) => value.toLowerCase());
    return this;
  }

  /// Converts the value to uppercase.
  ///
  /// Runs in the pre-processing phase, before any validation. The order in
  /// the chain does not matter — `toUpperCase` always runs first.
  ///
  /// ```dart
  /// V.string().toUpperCase().equals('HELLO').parse('hello'); // 'HELLO'
  /// V.string().equals('HELLO').toUpperCase().parse('hello'); // 'HELLO'
  /// ```
  VString toUpperCase() {
    _preTransform((value) => value.toUpperCase());
    return this;
  }

  /// Creates a [VArray] schema that validates a `List<String>`.
  ///
  /// ```dart
  /// V.string().email().array().parse(['a@b.com', 'c@d.com']);
  /// ```
  VArray<String> array() => VArray<String>(this);
}
