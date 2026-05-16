/// Machine-readable error code constants used by validators.
///
/// [VCode] holds only the generic fallbacks ([required], [invalidType],
/// [custom]). Type-specific codes live in sibling sealed classes —
/// [VStringCode], [VNumberCode], [VIntCode], [VDoubleCode], [VBoolCode],
/// [VDateCode], [VArrayCode], [VMapCode], [VObjectCode], [VEnumCode],
/// [VLiteralCode], [VUnionCode].
///
/// Every string emitted via `error.code` follows the `<type>.<action>`
/// convention (e.g. `string.email`, `number.positive`, `int.even`). The
/// three generic fallbacks (`required`, `invalid_type`, `custom`) stay
/// flat because they are type-agnostic — `VLocale` uses them as the
/// backstop when a prefixed key has no match.
///
/// Sealed classes are implicitly abstract, so these types exist only as
/// namespaces for `static const` fields — they are never instantiated or
/// extended outside this library.
///
/// ```dart
/// V.setLocale(const VLocale({
///   VCode.required: 'Campo obrigatório',
///   VStringCode.email: 'E-mail inválido',
///   VNumberCode.positive: 'Deve ser positivo',
/// }));
/// ```
sealed class VCode {
  /// Value is required (non-null). Generic fallback — prefer the
  /// type-specific constants (e.g. [VStringCode.required],
  /// [VIntCode.required]) which are what validators actually emit.
  static const required = 'required';

  /// Value has an unexpected type. Generic fallback — prefer the
  /// type-specific constants (e.g. [VStringCode.invalidType]).
  static const invalidType = 'invalid_type';

  /// Custom validation failed.
  static const custom = 'custom';
}

/// Error codes emitted by [VString] and its validators.
sealed class VStringCode {
  /// String value is null. Falls back to [VCode.required].
  static const required = 'string.required';

  /// Value provided to a string schema has the wrong type. Falls back
  /// to [VCode.invalidType].
  static const invalidType = 'string.invalid_type';

  /// String must not be empty.
  static const notEmpty = 'string.not_empty';

  /// String is shorter than the minimum length.
  static const tooSmall = 'string.too_small';

  /// String exceeds the maximum length.
  static const tooBig = 'string.too_big';

  /// String does not match the exact length.
  static const length = 'string.length';

  /// String is not parseable as an integer.
  static const integer = 'string.integer';

  /// String is not parseable as a finite number.
  static const numeric = 'string.numeric';

  /// String is not a valid email address.
  static const email = 'string.email';

  /// String is not a valid URL.
  static const url = 'string.url';

  /// String is not a valid bare domain.
  static const domain = 'string.domain';

  /// String is not a valid UUID.
  static const uuid = 'string.uuid';

  /// String is not a valid IP address.
  static const ip = 'string.ip';

  /// String does not match the expected format.
  static const format = 'string.format';

  /// String is not a valid date representation — distinct from
  /// [VDateCode] which operates on [DateTime] values.
  static const date = 'string.date';

  /// String is not a valid time.
  static const time = 'string.time';

  /// String does not contain the required substring.
  static const contains = 'string.contains';

  /// String does not start with the required prefix.
  static const startsWith = 'string.starts_with';

  /// String does not end with the required suffix.
  static const endsWith = 'string.ends_with';

  /// String is not equal to the expected value.
  static const equals = 'string.equals';

  /// String contains non-letter characters.
  static const alpha = 'string.alpha';

  /// String contains non-alphanumeric characters.
  static const alphanumeric = 'string.alphanumeric';

  /// String is not a valid slug.
  static const slug = 'string.slug';

  /// String does not meet password requirements.
  static const password = 'string.password';

  /// String is not a valid JWT.
  static const jwt = 'string.jwt';

  /// String is not a valid credit card number.
  static const card = 'string.card';

  /// String is not a valid phone number.
  static const phone = 'string.phone';

  /// String is not valid Base64.
  static const base64 = 'string.base64';

  /// String is not a valid hex color.
  static const hexColor = 'string.hex_color';

  /// String is not a valid MAC address.
  static const mac = 'string.mac';

  /// String is not a valid Semantic Version (SemVer).
  static const semver = 'string.semver';

  /// String is not a valid MongoDB ObjectId.
  static const mongoId = 'string.mongo_id';

  /// String is not a valid ULID.
  static const ulid = 'string.ulid';

  /// String is not a valid NanoID.
  static const nanoId = 'string.nano_id';

  /// String is not a valid IBAN.
  static const iban = 'string.iban';

  /// String is not valid JSON.
  static const json = 'string.json';

  /// String is not a valid CVV.
  static const cvv = 'string.cvv';

  /// String is not a valid postal code for the given pattern.
  static const postalCode = 'string.postal_code';

  /// String is not a valid tax ID for the given pattern.
  static const taxId = 'string.tax_id';

  /// String is not a valid license plate for the given pattern.
  static const licensePlate = 'string.license_plate';
}

/// Error codes shared by [VInt] and [VDouble] — range and sign checks
/// that apply to any numeric value.
sealed class VNumberCode {
  /// Number is below the minimum value.
  static const tooSmall = 'number.too_small';

  /// Number exceeds the maximum value.
  static const tooBig = 'number.too_big';

  /// Number is outside the allowed range.
  static const notInRange = 'number.not_in_range';

  /// Number is not positive.
  static const positive = 'number.positive';

  /// Number is not negative.
  static const negative = 'number.negative';

  /// Number is not a multiple of the required factor.
  static const multipleOf = 'number.multiple_of';

  /// Number is not finite.
  static const finite = 'number.finite';
}

/// Error codes emitted by [VInt] and its validators.
sealed class VIntCode {
  /// Int value is null. Falls back to [VCode.required].
  static const required = 'int.required';

  /// Value provided to an int schema has the wrong type. Falls back to
  /// [VCode.invalidType].
  static const invalidType = 'int.invalid_type';

  /// Integer is not even.
  static const even = 'int.even';

  /// Integer is not odd.
  static const odd = 'int.odd';

  /// Integer is not prime.
  static const prime = 'int.prime';
}

/// Error codes emitted by [VDouble] and its validators.
sealed class VDoubleCode {
  /// Double value is null. Falls back to [VCode.required].
  static const required = 'double.required';

  /// Value provided to a double schema has the wrong type. Falls back
  /// to [VCode.invalidType].
  static const invalidType = 'double.invalid_type';

  /// Double does not have a fractional part.
  static const decimal = 'double.decimal';

  /// Double is not a whole number — distinct from [VStringCode.integer]
  /// which validates that a string is parseable as an `int`.
  static const integer = 'double.integer';
}

/// Error codes emitted by [VBool] and its validators.
sealed class VBoolCode {
  /// Bool value is null. Falls back to [VCode.required].
  static const required = 'bool.required';

  /// Value provided to a bool schema has the wrong type. Falls back to
  /// [VCode.invalidType].
  static const invalidType = 'bool.invalid_type';

  /// Value is not `true`.
  static const isTrue = 'bool.is_true';

  /// Value is not `false`.
  static const isFalse = 'bool.is_false';
}

/// Error codes emitted by [VDate] and its validators.
sealed class VDateCode {
  /// Date value is null. Falls back to [VCode.required].
  static const required = 'date.required';

  /// Value provided to a date schema has the wrong type. Falls back to
  /// [VCode.invalidType].
  static const invalidType = 'date.invalid_type';

  /// Date is before the minimum date.
  static const tooSmall = 'date.too_small';

  /// Date is after the maximum date.
  static const tooBig = 'date.too_big';

  /// Date is outside the allowed range.
  static const notInRange = 'date.not_in_range';

  /// Date is not a weekday.
  static const weekday = 'date.weekday';

  /// Date is not a weekend.
  static const weekend = 'date.weekend';

  /// Age derived from date is outside the required range.
  static const age = 'date.age';

  /// Date is not today (y/m/d comparison in local time).
  static const isToday = 'date.is_today';

  /// Date is not the same y/m/d as the reference date.
  static const sameDay = 'date.same_day';

  /// Date's y/m/d is not strictly after today.
  static const afterToday = 'date.after_today';

  /// Date's y/m/d is not strictly before today.
  static const beforeToday = 'date.before_today';
}

/// Error codes emitted by [VArray] and its validators.
sealed class VArrayCode {
  /// Array value is null. Falls back to [VCode.required].
  static const required = 'array.required';

  /// Value provided to an array schema has the wrong type. Falls back
  /// to [VCode.invalidType].
  static const invalidType = 'array.invalid_type';

  /// Array has fewer elements than the minimum.
  static const tooSmall = 'array.too_small';

  /// Array has more elements than the maximum.
  static const tooBig = 'array.too_big';

  /// Array contains duplicate values.
  static const unique = 'array.unique';

  /// Array does not contain all required values.
  static const containsAll = 'array.contains_all';
}

/// Error codes emitted by [VMap] and its validators.
sealed class VMapCode {
  /// Map value is null. Falls back to [VCode.required].
  static const required = 'map.required';

  /// Value provided to a map schema has the wrong type. Falls back to
  /// [VCode.invalidType].
  static const invalidType = 'map.invalid_type';

  /// Map contains an unrecognized key.
  static const unrecognizedKey = 'map.unrecognized_key';

  /// Two fields that should be equal are not.
  static const fieldsNotEqual = 'map.fields_not_equal';
}

/// Error codes emitted by [VObject] and its validators.
sealed class VObjectCode {
  /// Object value is null. Falls back to [VCode.required].
  static const required = 'object.required';

  /// Value provided to an object schema has the wrong type. Falls back
  /// to [VCode.invalidType].
  static const invalidType = 'object.invalid_type';

  /// Raw map input contains a key not declared on the schema. Emitted
  /// only by `safeParseRaw` / `parseRaw` and friends when the schema is
  /// marked `.strict()`.
  static const unrecognizedKey = 'object.unrecognized_key';

  /// Two object fields declared via `equalFields` are not equal.
  static const fieldsNotEqual = 'object.fields_not_equal';
}

/// Error codes emitted by [VEnum] and its validators.
sealed class VEnumCode {
  /// Enum value is null. Falls back to [VCode.required].
  static const required = 'enum.required';

  /// Value provided to an enum schema has the wrong type. Falls back
  /// to [VCode.invalidType].
  static const invalidType = 'enum.invalid_type';

  /// Value is not a valid enum member.
  static const invalid = 'enum.invalid';
}

/// Error codes emitted by [VLiteral] and its validators.
sealed class VLiteralCode {
  /// Literal value is null. Falls back to [VCode.required].
  static const required = 'literal.required';

  /// Value provided to a literal schema has the wrong type. Falls back
  /// to [VCode.invalidType].
  static const invalidType = 'literal.invalid_type';

  /// Value does not match the expected literal.
  static const invalid = 'literal.invalid';
}

/// Error codes emitted by [VUnion] and its validators.
sealed class VUnionCode {
  /// Union value is null. Falls back to [VCode.required].
  static const required = 'union.required';

  /// Value provided to a union schema has the wrong type. Falls back
  /// to [VCode.invalidType].
  static const invalidType = 'union.invalid_type';

  /// Value does not match any union option.
  static const invalid = 'union.invalid';
}
