/// Machine-readable error code constants used by validators.
///
/// These codes are used as keys for locale translations and can be
/// extended by external packages.
///
/// ```dart
/// V.setLocale(const VLocale({
///   VCode.required: 'Campo obrigatório',
/// }));
/// ```
abstract class VCode {
  /// Value is required (non-null).
  static const required = 'required';

  /// Value has an unexpected type.
  static const invalidType = 'invalid_type';

  // String

  /// String must not be empty.
  static const notEmpty = 'not_empty';

  /// String is shorter than the minimum length.
  static const stringTooSmall = 'string.too_small';

  /// String exceeds the maximum length.
  static const stringTooBig = 'string.too_big';

  /// String does not match the exact length.
  static const stringLength = 'string.length';

  /// String is not a valid email address.
  static const invalidEmail = 'invalid_email';

  /// String is not a valid URL.
  static const invalidUrl = 'invalid_url';

  /// String is not a valid UUID.
  static const invalidUuid = 'invalid_uuid';

  /// String is not a valid IP address.
  static const invalidIp = 'invalid_ip';

  /// String does not match the expected format.
  static const invalidFormat = 'invalid_format';

  /// String is not a valid date.
  static const invalidDate = 'invalid_date';

  /// String is not a valid time.
  static const invalidTime = 'invalid_time';

  /// String does not contain the required substring.
  static const contains = 'contains';

  /// String does not start with the required prefix.
  static const startsWith = 'starts_with';

  /// String does not end with the required suffix.
  static const endsWith = 'ends_with';

  /// String is not equal to the expected value.
  static const equals = 'equals';

  /// String contains non-letter characters.
  static const alpha = 'alpha';

  /// String contains non-alphanumeric characters.
  static const alphanumeric = 'alphanumeric';

  /// String is not a valid slug.
  static const slug = 'slug';

  /// String does not meet password requirements.
  static const password = 'password';

  /// String is not a valid JWT.
  static const jwt = 'jwt';

  /// String is not a valid credit card number.
  static const card = 'card';

  /// String is not a valid phone number.
  static const invalidPhone = 'invalid_phone';

  /// String is not valid Base64.
  static const base64 = 'base64';

  /// String is not a valid hex color.
  static const hexColor = 'hex_color';

  /// String is not a valid MAC address.
  static const mac = 'mac';

  /// String is not a valid Semantic Version (SemVer).
  static const semver = 'semver';

  /// String is not a valid MongoDB ObjectId.
  static const mongoId = 'mongo_id';

  /// String is not a valid ULID.
  static const ulid = 'ulid';

  /// String is not a valid NanoID.
  static const nanoId = 'nano_id';

  /// String is not a valid IBAN.
  static const iban = 'iban';

  /// String is not valid JSON.
  static const json = 'json';

  /// String is not a valid CVV.
  static const cvv = 'cvv';

  /// String is not a valid postal code for the given pattern.
  static const postalCode = 'postal_code';

  /// String is not a valid tax ID for the given pattern.
  static const taxId = 'tax_id';

  /// String is not a valid license plate for the given pattern.
  static const licensePlate = 'license_plate';

  // Number

  /// Number is below the minimum value.
  static const numberTooSmall = 'number.too_small';

  /// Number exceeds the maximum value.
  static const numberTooBig = 'number.too_big';

  /// Number is outside the allowed range.
  static const numberNotInRange = 'number.not_in_range';

  /// Number is not positive.
  static const positive = 'positive';

  /// Number is not negative.
  static const negative = 'negative';

  /// Number is not a multiple of the required factor.
  static const multipleOf = 'multiple_of';

  /// Number is not even.
  static const even = 'even';

  /// Number is not odd.
  static const odd = 'odd';

  /// Number is not prime.
  static const prime = 'prime';

  /// Number is not finite.
  static const finite = 'finite';

  /// Number is not a decimal.
  static const decimal = 'decimal';

  /// Number is not an integer.
  static const integer = 'integer';

  // Bool

  /// Value is not `true`.
  static const isTrue = 'is_true';

  /// Value is not `false`.
  static const isFalse = 'is_false';

  // Date

  /// Date is before the minimum date.
  static const dateTooSmall = 'date.too_small';

  /// Date is after the maximum date.
  static const dateTooBig = 'date.too_big';

  /// Date is outside the allowed range.
  static const dateNotInRange = 'date.not_in_range';

  /// Date is not a weekday.
  static const weekday = 'weekday';

  /// Date is not a weekend.
  static const weekend = 'weekend';

  /// Age derived from date is outside the required range.
  static const age = 'age';

  // Array

  /// Array has fewer elements than the minimum.
  static const arrayTooSmall = 'array.too_small';

  /// Array has more elements than the maximum.
  static const arrayTooBig = 'array.too_big';

  /// Array contains duplicate values.
  static const unique = 'unique';

  /// Array does not contain all required values.
  static const containsAll = 'contains_all';

  // Composite

  /// Value is not a valid enum member.
  static const invalidEnum = 'invalid_enum';

  /// Value does not match the expected literal.
  static const invalidLiteral = 'invalid_literal';

  /// Value does not match any union option.
  static const invalidUnion = 'invalid_union';

  /// Map contains an unrecognized key.
  static const unrecognizedKey = 'unrecognized_key';

  /// Two fields that should be equal are not.
  static const fieldsNotEqual = 'fields_not_equal';

  /// Custom validation failed.
  static const custom = 'custom';
}
