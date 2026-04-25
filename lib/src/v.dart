import 'dart:core' as core;
import 'dart:core';

import 'package:validart/src/types/type.dart';
import 'package:validart/src/utils/date_parser.dart';
import 'package:validart/src/v_locale.dart';

/// Entry point for creating validation schemas.
///
/// Provides static factory methods for all supported types.
///
/// ```dart
/// final schema = V.string().email();
/// schema.parse('user@mail.com');
/// ```
sealed class V {
  static VLocale _locale = const VLocale();

  /// Provides coercion schemas that convert input values before validation.
  static final VCoerce coerce = VCoerce();

  /// Sets the locale used for error messages.
  ///
  /// ```dart
  /// V.setLocale(const VLocale({'required': 'Campo obrigatório'}));
  /// ```
  static void setLocale(VLocale locale) => _locale = locale;

  /// Returns the current locale.
  static VLocale get locale => _locale;

  /// Translates an error [code] with optional [params].
  static String t(String code, [Map<String, dynamic> params = const {}]) =>
      _locale.translate(code, params);

  /// Creates a [VString] schema.
  ///
  /// Pass [message] to override the default translation for the `required`
  /// error (when input is `null` and the schema is neither `nullable()`
  /// nor has a `defaultValue`). The factory-level [message] only applies
  /// to the `required` error — it is consumed before the validation
  /// pipeline starts. Pass [invalidTypeMessage] to override the default
  /// translation for the `invalid_type` error (input is non-null but
  /// has the wrong runtime type, e.g. `42` against `V.string()`); the
  /// two parameters are independent and can be set together. `VEnum`
  /// and `VLiteral` accept [invalidTypeMessage] for API uniformity but
  /// emit `enum.invalid` / `literal.invalid` codes (not `invalid_type`),
  /// so the override is a no-op there — use a custom locale entry to
  /// customize those.
  ///
  /// Individual validator methods (`.email(message: ...)`,
  /// `.min(n, message: ...)`, `.refine(fn, message: ...)`, ...) accept
  /// their own [message] parameter which customizes the error produced by
  /// that specific validator inside the pipeline. The two never overlap:
  /// the factory-level ones fire before the pipeline starts, the
  /// validator-level one fires when that validator rejects a value.
  ///
  /// ```dart
  /// V.string().email().min(5);
  /// V.string(message: 'Name is required').min(1);
  /// V.string(
  ///   message: 'Name is required',
  ///   invalidTypeMessage: 'Name must be text',
  /// );
  ///
  /// // Both levels on the same schema — each fires in its own scenario.
  /// V.string(message: 'Name is required')
  ///     .min(3, message: (n) => 'At least $n chars');
  /// ```
  static VString string({String? message, String? invalidTypeMessage}) =>
      VString(message: message, invalidTypeMessage: invalidTypeMessage);

  /// Creates a [VBool] schema. See [string] for [message] and
  /// [invalidTypeMessage].
  ///
  /// ```dart
  /// V.bool().isTrue();
  /// V.bool(message: 'You must accept the terms').isTrue();
  /// ```
  static VBool bool({String? message, String? invalidTypeMessage}) =>
      VBool(message: message, invalidTypeMessage: invalidTypeMessage);

  /// Creates a [VInt] schema. See [string] for [message] and
  /// [invalidTypeMessage].
  ///
  /// ```dart
  /// V.int().positive().min(1);
  /// V.int(message: 'Age is required').between(0, 150);
  /// ```
  static VInt int({String? message, String? invalidTypeMessage}) =>
      VInt(message: message, invalidTypeMessage: invalidTypeMessage);

  /// Creates a [VDouble] schema. See [string] for [message] and
  /// [invalidTypeMessage].
  ///
  /// ```dart
  /// V.double().finite().positive();
  /// ```
  static VDouble double({String? message, String? invalidTypeMessage}) =>
      VDouble(message: message, invalidTypeMessage: invalidTypeMessage);

  /// Creates a [VDate] schema. See [string] for [message] and
  /// [invalidTypeMessage].
  ///
  /// ```dart
  /// V.date().after(DateTime(2024));
  /// ```
  static VDate date({String? message, String? invalidTypeMessage}) =>
      VDate(message: message, invalidTypeMessage: invalidTypeMessage);

  /// Creates a [VMap] schema with the given field [schema]. See [string]
  /// for [message] and [invalidTypeMessage].
  ///
  /// ```dart
  /// V.map({'name': V.string(), 'age': V.int()});
  /// ```
  static VMap map(
    Map<String, VType> schema, {
    String? message,
    String? invalidTypeMessage,
  }) =>
      VMap(schema, message: message, invalidTypeMessage: invalidTypeMessage);

  /// Creates a [VObject] schema for type-safe entity validation. Chain
  /// [VObject.field] to add type-safe field extractors. See [string] for
  /// [message] and [invalidTypeMessage].
  ///
  /// ```dart
  /// V.object<User>()
  ///     .field('name', (u) => u.name, V.string());
  /// ```
  static VObject<T> object<T>({String? message, String? invalidTypeMessage}) =>
      VObject<T>(message: message, invalidTypeMessage: invalidTypeMessage);

  /// Creates a [VArray] schema for the given [element] type. See [string]
  /// for [message] and [invalidTypeMessage].
  ///
  /// ```dart
  /// V.array(V.string().email());
  /// ```
  static VArray<T> array<T>(
    VType<T> element, {
    String? message,
    String? invalidTypeMessage,
  }) =>
      VArray<T>(element,
          message: message, invalidTypeMessage: invalidTypeMessage);

  /// Creates a [VEnum] schema accepting the given enum [values]. See
  /// [string] for [message]. [invalidTypeMessage] is accepted for API
  /// uniformity but never fires — `VEnum` emits `enum.invalid` instead
  /// of `invalid_type`.
  ///
  /// ```dart
  /// V.enm(Color.values);
  /// ```
  static VEnum<T> enm<T extends Enum>(
    List<T> values, {
    String? message,
    String? invalidTypeMessage,
  }) =>
      VEnum<T>(values,
          message: message, invalidTypeMessage: invalidTypeMessage);

  /// Creates a [VLiteral] schema accepting only the given [value]. See
  /// [string] for [message]. [invalidTypeMessage] is accepted for API
  /// uniformity but never fires — `VLiteral` emits `literal.invalid`
  /// instead of `invalid_type`.
  ///
  /// ```dart
  /// V.literal('active');
  /// ```
  static VLiteral<T> literal<T>(
    T value, {
    String? message,
    String? invalidTypeMessage,
  }) =>
      VLiteral<T>(value,
          message: message, invalidTypeMessage: invalidTypeMessage);

  /// Creates a [VUnion] schema accepting any of the given [options]. See
  /// [string] for [message] and [invalidTypeMessage].
  ///
  /// ```dart
  /// V.union([V.string(), V.int()]);
  /// ```
  static VUnion union(
    List<VType> options, {
    String? message,
    String? invalidTypeMessage,
  }) =>
      VUnion(options, message: message, invalidTypeMessage: invalidTypeMessage);
}

/// Provides coercion schemas that convert input values to the target type.
///
/// ```dart
/// V.coerce.int().parse('42'); // 42
/// V.coerce.string().parse(123); // '123'
/// ```
class VCoerce {
  /// Creates a [VInt] schema that coerces values to [int].
  ///
  /// Accepts [int], [double], [String], and [bool] inputs.
  ///
  /// ```dart
  /// V.coerce.int().parse('42');   // 42
  /// V.coerce.int().parse(3.14);  // 3
  /// V.coerce.int().parse(true);  // 1
  /// ```
  VInt int() {
    final schema = VInt();

    schema.coercer = (value) {
      if (value is core.int) return value;
      if (value is core.double) return value.toInt();
      if (value is String) return num.parse(value).toInt();
      if (value is core.bool) return value ? 1 : 0;
      throw FormatException('Cannot coerce $value to int');
    };

    return schema;
  }

  /// Creates a [VDouble] schema that coerces values to [double].
  ///
  /// Accepts [double], [int], [String], and [bool] inputs.
  ///
  /// ```dart
  /// V.coerce.double().parse('3.14'); // 3.14
  /// V.coerce.double().parse(42);     // 42.0
  /// V.coerce.double().parse(true);   // 1.0
  /// ```
  VDouble double() {
    final schema = VDouble();

    schema.coercer = (value) {
      if (value is core.double) return value;
      if (value is core.int) return value.toDouble();
      if (value is String) return num.parse(value).toDouble();
      if (value is core.bool) return value ? 1.0 : 0.0;
      throw FormatException('Cannot coerce $value to double');
    };

    return schema;
  }

  /// Creates a [VString] schema that coerces values to [String].
  ///
  /// Calls `toString()` on the input.
  ///
  /// ```dart
  /// V.coerce.string().parse(42);   // '42'
  /// V.coerce.string().parse(true); // 'true'
  /// ```
  VString string() {
    final schema = VString();
    schema.coercer = (value) => value.toString();

    return schema;
  }

  /// Creates a [VBool] schema that coerces values to [bool].
  ///
  /// Accepts [bool], [String] (`'true'`, `'false'`, `'1'`, `'0'`), and
  /// [int] inputs.
  ///
  /// ```dart
  /// V.coerce.bool().parse('true'); // true
  /// V.coerce.bool().parse(0);      // false
  /// ```
  VBool bool() {
    final schema = VBool();

    schema.coercer = (value) {
      if (value is core.bool) return value;
      if (value is String) {
        if (value == 'true' || value == '1') return true;
        if (value == 'false' || value == '0') return false;
      }
      if (value is core.int) return value != 0;
      throw FormatException('Cannot coerce $value to bool');
    };

    return schema;
  }

  /// Creates a [VDate] schema that coerces values to [DateTime].
  ///
  /// Accepts a [DateTime] directly, or a [String] in ISO 8601 or any of
  /// the formats in [defaultDateFormats] (BR `DD/MM/YYYY`, US
  /// `MM/DD/YYYY`, EU `DD.MM.YYYY`, dashed and compact variants).
  /// Calendar-invalid dates (like `30/02/2024`) throw.
  ///
  /// For strict format validation where ambiguity matters (e.g.
  /// rejecting `01/15/2024` in a BR-only pipeline), chain
  /// `V.string().date(format: 'DD/MM/YYYY')` before conversion.
  ///
  /// ```dart
  /// V.coerce.date().parse('2024-01-15'); // DateTime(2024, 1, 15)
  /// V.coerce.date().parse('15/01/2024'); // DateTime(2024, 1, 15)
  /// V.coerce.date().parse('01/15/2024'); // DateTime(2024, 1, 15)
  /// ```
  VDate date() {
    final schema = VDate();

    schema.coercer = (value) {
      if (value is DateTime) return value;

      if (value is String) {
        final parsed = tryParseFlexibleDate(value);

        if (parsed != null) return parsed;

        throw FormatException('Cannot coerce "$value" to DateTime');
      }

      throw FormatException('Cannot coerce $value to DateTime');
    };

    return schema;
  }
}
