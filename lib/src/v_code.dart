abstract class VCode {
  static const required = 'required';
  static const invalidType = 'invalid_type';

  // String
  static const notEmpty = 'not_empty';
  static const tooSmall = 'too_small';
  static const tooBig = 'too_big';
  static const length = 'length';
  static const invalidEmail = 'invalid_email';
  static const invalidUrl = 'invalid_url';
  static const invalidUuid = 'invalid_uuid';
  static const invalidIp = 'invalid_ip';
  static const invalidFormat = 'invalid_format';
  static const invalidDate = 'invalid_date';
  static const invalidTime = 'invalid_time';
  static const contains = 'contains';
  static const startsWith = 'starts_with';
  static const endsWith = 'ends_with';
  static const equals = 'equals';
  static const alpha = 'alpha';
  static const alphanumeric = 'alphanumeric';
  static const slug = 'slug';
  static const password = 'password';
  static const jwt = 'jwt';
  static const card = 'card';
  static const invalidPhone = 'invalid_phone';

  // Number
  static const positive = 'positive';
  static const negative = 'negative';
  static const notInRange = 'not_in_range';
  static const multipleOf = 'multiple_of';
  static const even = 'even';
  static const odd = 'odd';
  static const prime = 'prime';
  static const finite = 'finite';
  static const decimal = 'decimal';
  static const integer = 'integer';

  // Bool
  static const isTrue = 'is_true';
  static const isFalse = 'is_false';

  // Date
  static const weekday = 'weekday';
  static const weekend = 'weekend';

  // Array
  static const unique = 'unique';
  static const containsAll = 'contains_all';

  // Composite
  static const invalidEnum = 'invalid_enum';
  static const invalidLiteral = 'invalid_literal';
  static const invalidUnion = 'invalid_union';
  static const unrecognizedKey = 'unrecognized_key';
  static const fieldsNotEqual = 'fields_not_equal';
  static const custom = 'custom';
}
