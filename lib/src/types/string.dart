part of 'type.dart';

/// Validates [String] values.
///
/// ```dart
/// final schema = V.string().email().min(5);
/// schema.parse('user@mail.com'); // 'user@mail.com'
/// ```
class VString extends VType<String> {
  @override
  String get typeName => 'string';

  /// Creates a [VString]. Pass [message] to override the default
  /// translation used when the input is `null`.
  VString({super.message});

  @override
  VString add(
    Validator<String> validator, {
    String? message,
    List<Object>? path,
    Set<String>? dependsOn,
  }) {
    super.add(validator, message: message, path: path, dependsOn: dependsOn);
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
  VString preprocessAsync(Future<Object?> Function(Object? value) fn) {
    super.preprocessAsync(fn);
    return this;
  }

  @override
  VString refine(
    bool Function(String value) check, {
    String? message,
    String? code,
    Set<String>? dependsOn,
  }) {
    super.refine(check, message: message, code: code, dependsOn: dependsOn);
    return this;
  }

  @override
  VString refineAsync(
    Future<bool> Function(String value) check, {
    String? message,
    String? code,
    Duration? timeout,
    Set<String>? dependsOn,
  }) {
    super.refineAsync(
      check,
      message: message,
      code: code,
      timeout: timeout,
      dependsOn: dependsOn,
    );
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
    return add(const NotEmptyValidator(), message: message);
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
    return add(MinLengthValidator(min: length), message: message?.call(length));
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
    return add(MaxLengthValidator(max: length), message: message?.call(length));
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
    return add(LengthValidator(length: len), message: message?.call(len));
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
    return add(const EmailValidator(), message: message);
  }

  /// Validates that the string is a valid URL.
  ///
  /// Accepts `http` and `https` by default. Pass [schemes] to allow other
  /// protocols (`ftp`, `ws`, `file`, etc.).
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.string().url().validate('https://example.com');       // true
  /// V.string().url().validate('ftp://example.com');          // false
  /// V.string().url(schemes: {'http', 'https', 'ftp'})
  ///   .validate('ftp://example.com');                        // true
  /// ```
  VString url({Set<String>? schemes, String? message}) {
    return add(
      schemes == null ? const UrlValidator() : UrlValidator(schemes: schemes),
      message: message,
    );
  }

  /// Validates that the string is a valid UUID (versions 1–8).
  ///
  /// Pass [version] to restrict to a specific [UuidVersion] (e.g.
  /// `UuidVersion.v4` for random, `UuidVersion.v7` for timestamp-ordered).
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.string().uuid().validate('550e8400-e29b-41d4-a716-446655440000');
  /// // true (v4)
  ///
  /// V.string()
  ///   .uuid(version: UuidVersion.v7)
  ///   .validate('018fcb2e-ea3f-7a3d-b91e-8f2e0c9b33d9'); // true
  /// ```
  VString uuid({UuidVersion? version, String? message}) {
    return add(UuidValidator(version: version), message: message);
  }

  /// Validates that the string is a valid ULID (26 chars Crockford Base32).
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.string().ulid().validate('01ARZ3NDEKTSV4RRFFQ69G5FAV'); // true
  /// ```
  VString ulid({String? message}) {
    return add(const UlidValidator(), message: message);
  }

  /// Validates that the string is a valid NanoID.
  ///
  /// Uses the URL-safe alphabet (`A-Z`, `a-z`, `0-9`, `_`, `-`) with the
  /// given [length] (default 21 — the NanoID library default).
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.string().nanoId().validate('V1StGXR8_Z5jdHi6B-myT');      // true
  /// V.string().nanoId(length: 10).validate('V1StGXR8_Z'); // true
  /// ```
  VString nanoId({int length = 21, String? message}) {
    return add(NanoIdValidator(length: length), message: message);
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
    return add(const IpValidator(), message: message);
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
    return add(PatternValidator(pattern: regex), message: message);
  }

  /// Validates that the string is a real calendar date.
  ///
  /// Without [format], accepts any of the known defaults (ISO, BR, US, EU)
  /// and the string passes if at least one of them parses to a
  /// calendar-valid date. With [format], the string must match that
  /// format exactly. Supported tokens: `YYYY`, `MM`, `DD` — any other
  /// character is a literal separator.
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.string().date().validate('2024-01-15'); // true (ISO)
  /// V.string().date().validate('15/01/2024'); // true (BR)
  /// V.string().date().validate('01/15/2024'); // true (US)
  /// V.string().date().validate('2024-02-30'); // false (invalid)
  ///
  /// V.string().date(format: 'DD/MM/YYYY').validate('15/01/2024'); // true
  /// V.string().date(format: 'DD/MM/YYYY').validate('2024-01-15'); // false
  /// ```
  VString date({String? format, String? message}) {
    return add(DateStringValidator(format: format), message: message);
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
    return add(const TimeValidator(), message: message);
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
    return add(ContainsValidator(substring: value), message: message);
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
    return add(StartsWithValidator(prefix: prefix), message: message);
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
    return add(EndsWithValidator(suffix: suffix), message: message);
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
    return add(EqualsValidator(expected: value), message: message);
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
    return add(const AlphaValidator(), message: message);
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
    return add(const AlphanumericValidator(), message: message);
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
    return add(const SlugValidator(), message: message);
  }

  /// Validates that the string meets password strength requirements.
  ///
  /// Requires at least 8 characters, including uppercase, lowercase, digit,
  /// and a special character. Default accepted special chars are
  /// `!@#$%^&*(),.?":{}|<>`; pass [specialChars] to override (each
  /// character in the string is treated as an allowed special).
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.string().password().validate('Str0ng!Pass');           // true
  /// V.string().password().validate('Str0ng_Pass');           // false ('_' not in default set)
  /// V.string().password(specialChars: r'!@#$%^&*()-_+=<>?')
  ///   .validate('Str0ng_Pass');                              // true
  /// ```
  VString password({String? specialChars, String? message}) {
    return add(
      specialChars == null
          ? const PasswordValidator()
          : PasswordValidator(specialChars: specialChars),
      message: message,
    );
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
    return add(const JwtValidator(), message: message);
  }

  /// Validates that the string is a valid credit card number.
  ///
  /// Accepts digits with or without separators (spaces or dashes) by
  /// default. When [brands] is provided, the number must match at least
  /// one of the given [CardBrandPattern]s; otherwise any Luhn-valid number
  /// is accepted. The [mode] field narrows which input shape is accepted
  /// — see [ValidationMode].
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.string().card().validate('4111111111111111'); // true
  /// V.string().card().validate('4111 1111 1111 1111'); // true
  ///
  /// V.string()
  ///   .card(brands: [const VisaBrand(), const MastercardBrand()])
  ///   .validate('4111111111111111'); // true (Visa)
  ///
  /// V.string()
  ///   .card(mode: ValidationMode.unformatted)
  ///   .validate('4111 1111 1111 1111'); // false (has spaces)
  /// ```
  VString card({
    List<CardBrandPattern>? brands,
    ValidationMode mode = ValidationMode.any,
    String? message,
  }) {
    return add(CardValidator(brands: brands, mode: mode), message: message);
  }

  /// Validates that the string is a valid CVV/CVC (3 or 4 digits).
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.string().cvv().validate('123');  // true
  /// V.string().cvv().validate('1234'); // true
  /// V.string().cvv().validate('12');   // false
  /// ```
  VString cvv({String? message}) {
    return add(const CvvValidator(), message: message);
  }

  /// Validates that the string is valid Base64 (RFC 4648).
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.string().base64().validate('SGVsbG8='); // true
  /// ```
  VString base64({String? message}) {
    return add(const Base64Validator(), message: message);
  }

  /// Validates that the string is a valid hex color (`#FFF` or `#FFFFFF`).
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.string().hexColor().validate('#FF0000'); // true
  /// V.string().hexColor().validate('#F00');    // true
  /// V.string().hexColor().validate('red');     // false
  /// ```
  VString hexColor({String? message}) {
    return add(const HexColorValidator(), message: message);
  }

  /// Validates that the string is a valid MAC address.
  ///
  /// Accepts colon or dash separators (`AA:BB:CC:DD:EE:FF` or
  /// `AA-BB-CC-DD-EE-FF`), consistent within the value.
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.string().mac().validate('AA:BB:CC:DD:EE:FF'); // true
  /// V.string().mac().validate('AA-BB-CC-DD-EE-FF'); // true
  /// ```
  VString mac({String? message}) {
    return add(const MacValidator(), message: message);
  }

  /// Validates that the string is a valid Semantic Version (SemVer 2.0).
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.string().semver().validate('1.2.3');           // true
  /// V.string().semver().validate('1.0.0-alpha.1');   // true
  /// V.string().semver().validate('1.0.0+build.123'); // true
  /// ```
  VString semver({String? message}) {
    return add(const SemverValidator(), message: message);
  }

  /// Validates that the string is a valid MongoDB ObjectId (24 hex chars).
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.string().mongoId().validate('507f1f77bcf86cd799439011'); // true
  /// ```
  VString mongoId({String? message}) {
    return add(const MongoIdValidator(), message: message);
  }

  /// Validates that the string is a valid IBAN (ISO 13616).
  ///
  /// Uses the mod-97 check-digit algorithm; accepts values with or
  /// without spaces.
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.string().iban().validate('GB82 WEST 1234 5698 7654 32'); // true
  /// ```
  VString iban({String? message}) {
    return add(const IbanValidator(), message: message);
  }

  /// Validates that the string parses as valid JSON.
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.string().json().validate('{"a": 1}'); // true
  /// V.string().json().validate('not json'); // false
  /// ```
  VString json({String? message}) {
    return add(const JsonValidator(), message: message);
  }

  /// Validates that the string is parseable as a Dart `int` (decimal base).
  ///
  /// Accepts an optional leading `+`/`-` followed by decimal digits only.
  /// Does not convert the output — the pipeline value remains a `String`.
  /// For conversion use [V.coerce.int] instead.
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.string().integer().validate('42'); // true
  /// V.string().integer().validate('-42'); // true
  /// V.string().integer().validate('3.14'); // false
  /// V.string().integer().validate('42e3'); // false
  /// ```
  VString integer({String? message}) {
    return add(const IntegerStringValidator(), message: message);
  }

  /// Validates that the string is parseable as a finite `double`.
  ///
  /// Accepts integer, decimal and scientific notation. Rejects `NaN`,
  /// `Infinity`, `-Infinity`, whitespace padding and empty strings. Does
  /// not convert the output — the pipeline value remains a `String`. For
  /// conversion use [V.coerce.double] instead.
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.string().numeric().validate('3.14'); // true
  /// V.string().numeric().validate('42e3'); // true
  /// V.string().numeric().validate('NaN'); // false
  /// V.string().numeric().validate('Infinity'); // false
  /// ```
  VString numeric({String? message}) {
    return add(const NumericStringValidator(), message: message);
  }

  /// Validates that the string is a valid postal code for at least one
  /// of the given [patterns].
  ///
  /// Built-in patterns: [UsZipPattern], [CaPostalCodePattern],
  /// [UkPostcodePattern]. External packages can extend
  /// [PostalCodePattern] to add country-specific rules (e.g. BR CEP in
  /// `validart_br`).
  ///
  /// Pass multiple patterns to accept inputs from any of several
  /// countries — validation succeeds when the value matches any of them.
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.string().postalCode(patterns: [const UsZipPattern()])
  ///   .validate('94103-1234'); // true
  ///
  /// V.string().postalCode(patterns: [
  ///   const UsZipPattern(),
  ///   const CaPostalCodePattern(),
  ///   const UkPostcodePattern(),
  /// ]).validate('SW1A 1AA'); // true
  /// ```
  VString postalCode({
    required List<PostalCodePattern> patterns,
    String? message,
  }) {
    return add(PostalCodeValidator(patterns: patterns), message: message);
  }

  /// Validates that the string is a valid tax ID for at least one of
  /// the given [patterns].
  ///
  /// Built-in patterns: [UsSsnPattern], [UkNiNumberPattern],
  /// [CaSinPattern]. Country-specific IDs with custom check digits
  /// (e.g. BR CPF/CNPJ) live in extension packages like `validart_br`.
  ///
  /// Pass multiple patterns to accept inputs from any of several
  /// countries — validation succeeds when the value matches any of them.
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.string().taxId(patterns: [const UsSsnPattern()])
  ///   .validate('123-45-6789'); // true
  ///
  /// V.string().taxId(patterns: [
  ///   const UsSsnPattern(),
  ///   const UkNiNumberPattern(),
  /// ]).validate('AB123456C'); // true
  /// ```
  VString taxId({required List<TaxIdPattern> patterns, String? message}) {
    return add(TaxIdValidator(patterns: patterns), message: message);
  }

  /// Validates that the string is a valid license plate for at least
  /// one of the given [patterns].
  ///
  /// Built-in pattern: [UkPlatePattern]. Most countries vary heavily by
  /// state/province — implement [LicensePlatePattern] in an extension
  /// package to add your own.
  ///
  /// Pass multiple patterns to accept inputs from any of several
  /// countries — validation succeeds when the value matches any of them.
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.string().licensePlate(patterns: [const UkPlatePattern()])
  ///   .validate('AB12 CDE'); // true
  ///
  /// V.string().licensePlate(patterns: [
  ///   const UkPlatePattern(),
  ///   const BrMercosulPattern(), // from validart_br
  /// ]);
  /// ```
  VString licensePlate({
    required List<LicensePlatePattern> patterns,
    String? message,
  }) {
    return add(LicensePlateValidator(patterns: patterns), message: message);
  }

  /// Validates that the string is a valid phone number for at least one
  /// of the given [patterns].
  ///
  /// Defaults to a single [E164PhonePattern] when [patterns] is omitted,
  /// matching the E.164 international format. Pass one or more patterns
  /// to plug country-specific rules (for example, `BrPhonePattern` from
  /// `validart_br`).
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.string().phone().validate('+5511999999999'); // true (E.164 default)
  ///
  /// V.string().phone(patterns: [const MyCountryPhonePattern()])
  ///   .validate('(11) 98765-4321');
  ///
  /// V.string().phone(patterns: [
  ///   const BrPhonePattern(),
  ///   const UsPhonePattern(),
  /// ]).validate('+14155552671'); // true
  /// ```
  VString phone({List<PhonePattern>? patterns, String? message}) {
    return add(
      PhoneValidator(patterns: patterns ?? const [E164PhonePattern()]),
      message: message,
    );
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

  /// Converts the value to `PascalCase`.
  ///
  /// Runs in the pre-processing phase. Words are extracted from the input
  /// (respecting case boundaries, digits, and separators like ` `, `_`,
  /// `-`); any character outside letters and digits is dropped. By default,
  /// accented characters are transliterated (`á`→`a`, `ç`→`c`); pass
  /// `keepAccents: true` to preserve them.
  ///
  /// ```dart
  /// V.string().toPascalCase().parse('hello world');     // 'HelloWorld'
  /// V.string().toPascalCase().parse('maçã fresca');     // 'MacaFresca'
  /// V.string().toPascalCase(keepAccents: true).parse('maçã fresca');
  /// // 'MaçãFresca'
  /// ```
  VString toPascalCase({bool keepAccents = false}) {
    _preTransform((value) {
      final normalized = keepAccents ? value : _stripAccents(value);

      return _splitWords(normalized).map(_capitalize).join('');
    });

    return this;
  }

  /// Converts the value to `camelCase`.
  ///
  /// Runs in the pre-processing phase. Same word-extraction rules as
  /// [toPascalCase], except the first word is lowercased. Use
  /// `keepAccents: true` to preserve accented characters (default strips
  /// them).
  ///
  /// ```dart
  /// V.string().toCamelCase().parse('hello world');     // 'helloWorld'
  /// V.string().toCamelCase().parse('São Paulo');       // 'saoPaulo'
  /// ```
  VString toCamelCase({bool keepAccents = false}) {
    _preTransform((value) {
      final normalized = keepAccents ? value : _stripAccents(value);
      final words = _splitWords(normalized);

      if (words.isEmpty) return '';

      final first = words.first.toLowerCase();
      final rest = words.skip(1).map(_capitalize).join('');

      return first + rest;
    });

    return this;
  }

  /// Converts the value to `snake_case`.
  ///
  /// Runs in the pre-processing phase. Words are extracted and joined with
  /// `_`; all characters are lowercased. Use `keepAccents: true` to
  /// preserve accented characters (default strips them).
  ///
  /// ```dart
  /// V.string().toSnakeCase().parse('HelloWorld');  // 'hello_world'
  /// V.string().toSnakeCase().parse('Maçã Fresca'); // 'maca_fresca'
  /// ```
  VString toSnakeCase({bool keepAccents = false}) {
    _preTransform((value) {
      final normalized = keepAccents ? value : _stripAccents(value);

      return _splitWords(normalized).map((w) => w.toLowerCase()).join('_');
    });

    return this;
  }

  /// Converts the value to `SCREAMING_SNAKE_CASE`.
  ///
  /// Runs in the pre-processing phase. Words are extracted and joined with
  /// `_`; all characters are uppercased. Use `keepAccents: true` to
  /// preserve accented characters (default strips them).
  ///
  /// ```dart
  /// V.string().toScreamingSnakeCase().parse('helloWorld');
  /// // 'HELLO_WORLD'
  /// ```
  VString toScreamingSnakeCase({bool keepAccents = false}) {
    _preTransform((value) {
      final normalized = keepAccents ? value : _stripAccents(value);

      return _splitWords(normalized).map((w) => w.toUpperCase()).join('_');
    });

    return this;
  }

  /// Converts the value to a URL-friendly slug (`kebab-case` lowercase).
  ///
  /// Runs in the pre-processing phase. Words are extracted and joined with
  /// `-`; all characters are lowercased. By default, accented characters
  /// are transliterated (`São Paulo` → `sao-paulo`); pass
  /// `keepAccents: true` to preserve them.
  ///
  /// ```dart
  /// V.string().toSlug().parse('My Blog Post!'); // 'my-blog-post'
  /// V.string().toSlug().parse('São João');      // 'sao-joao'
  /// V.string().toSlug(keepAccents: true).parse('São João'); // 'são-joão'
  /// ```
  VString toSlug({bool keepAccents = false}) {
    _preTransform((value) {
      final normalized = keepAccents ? value : _stripAccents(value);

      return _splitWords(normalized).map((w) => w.toLowerCase()).join('-');
    });

    return this;
  }

  /// Creates a [VArray] schema that validates a `List<String>`.
  ///
  /// ```dart
  /// V.string().email().array().parse(['a@b.com', 'c@d.com']);
  /// ```
  VArray<String> array() => VArray<String>(this);
}

final RegExp _wordRegex = RegExp(
  r'\p{Lu}+(?=\p{Lu}\p{Ll})|\p{Lu}?\p{Ll}+|\p{Lu}+|\d+',
  unicode: true,
);

List<String> _splitWords(String input) {
  return _wordRegex.allMatches(input).map((m) => m.group(0)!).toList();
}

String _capitalize(String word) {
  if (word.isEmpty) return word;

  return word[0].toUpperCase() + word.substring(1).toLowerCase();
}

const Map<String, String> _accentMap = {
  'à': 'a',
  'á': 'a',
  'â': 'a',
  'ã': 'a',
  'ä': 'a',
  'å': 'a',
  'æ': 'ae',
  'ç': 'c',
  'è': 'e',
  'é': 'e',
  'ê': 'e',
  'ë': 'e',
  'ì': 'i',
  'í': 'i',
  'î': 'i',
  'ï': 'i',
  'ð': 'd',
  'ñ': 'n',
  'ò': 'o',
  'ó': 'o',
  'ô': 'o',
  'õ': 'o',
  'ö': 'o',
  'ø': 'o',
  'ù': 'u',
  'ú': 'u',
  'û': 'u',
  'ü': 'u',
  'ý': 'y',
  'ÿ': 'y',
  'ß': 'ss',
  'þ': 'th',
  'À': 'A',
  'Á': 'A',
  'Â': 'A',
  'Ã': 'A',
  'Ä': 'A',
  'Å': 'A',
  'Æ': 'AE',
  'Ç': 'C',
  'È': 'E',
  'É': 'E',
  'Ê': 'E',
  'Ë': 'E',
  'Ì': 'I',
  'Í': 'I',
  'Î': 'I',
  'Ï': 'I',
  'Ð': 'D',
  'Ñ': 'N',
  'Ò': 'O',
  'Ó': 'O',
  'Ô': 'O',
  'Õ': 'O',
  'Ö': 'O',
  'Ø': 'O',
  'Ù': 'U',
  'Ú': 'U',
  'Û': 'U',
  'Ü': 'U',
  'Ý': 'Y',
  'Þ': 'TH',
};

String _stripAccents(String input) {
  final buffer = StringBuffer();

  for (final char in input.split('')) {
    buffer.write(_accentMap[char] ?? char);
  }

  return buffer.toString();
}
