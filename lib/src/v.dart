import 'dart:core' as core;
import 'dart:core';

import 'package:validart/src/types/type.dart';
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
  /// pipeline starts.
  ///
  /// Individual validator methods (`.email(message: ...)`,
  /// `.min(n, message: ...)`, `.refine(fn, message: ...)`, ...) accept
  /// their own [message] parameter which customizes the error produced by
  /// that specific validator inside the pipeline. The two never overlap:
  /// the factory-level one fires on null input, the validator-level one
  /// fires when that validator rejects a non-null value.
  ///
  /// ```dart
  /// V.string().email().min(5);
  /// V.string(message: 'Name is required').min(1);
  ///
  /// // Both levels on the same schema — each fires in its own scenario.
  /// V.string(message: 'Name is required')
  ///     .min(3, message: (n) => 'At least $n chars');
  /// ```
  static VString string({String? message}) => VString(message: message);

  /// Creates a [VBool] schema. See [string] for [message].
  ///
  /// ```dart
  /// V.bool().isTrue();
  /// V.bool(message: 'You must accept the terms').isTrue();
  /// ```
  static VBool bool({String? message}) => VBool(message: message);

  /// Creates a [VInt] schema. See [string] for [message].
  ///
  /// ```dart
  /// V.int().positive().min(1);
  /// V.int(message: 'Age is required').between(0, 150);
  /// ```
  static VInt int({String? message}) => VInt(message: message);

  /// Creates a [VDouble] schema. See [string] for [message].
  ///
  /// ```dart
  /// V.double().finite().positive();
  /// ```
  static VDouble double({String? message}) => VDouble(message: message);

  /// Creates a [VDate] schema. See [string] for [message].
  ///
  /// ```dart
  /// V.date().after(DateTime(2024));
  /// ```
  static VDate date({String? message}) => VDate(message: message);

  /// Creates a [VMap] schema with the given field [schema]. See [string]
  /// for [message].
  ///
  /// ```dart
  /// V.map({'name': V.string(), 'age': V.int()});
  /// ```
  static VMap map(
    Map<String, VType> schema, {
    String? message,
  }) =>
      VMap(schema, message: message);

  /// Creates a [VObject] schema for type-safe entity validation. See
  /// [string] for [message].
  ///
  /// ```dart
  /// V.object<User>(configure: (o) {
  ///   o.field('name', (u) => u.name, V.string());
  /// });
  /// ```
  static VObject<T> object<T>({
    void Function(VObjectBuilder<T> o)? configure,
    String? message,
  }) =>
      VObject<T>(
        configure: configure,
        message: message,
      );

  /// Creates a [VArray] schema for the given [element] type. See [string]
  /// for [message].
  ///
  /// ```dart
  /// V.array(V.string().email());
  /// ```
  static VArray<T> array<T>(VType<T> element, {String? message}) =>
      VArray<T>(element, message: message);

  /// Creates a [VEnum] schema accepting the given enum [values]. See
  /// [string] for [message].
  ///
  /// ```dart
  /// V.enm(Color.values);
  /// ```
  static VEnum<T> enm<T extends Enum>(
    List<T> values, {
    String? message,
  }) =>
      VEnum<T>(values, message: message);

  /// Creates a [VLiteral] schema accepting only the given [value]. See
  /// [string] for [message].
  ///
  /// ```dart
  /// V.literal('active');
  /// ```
  static VLiteral<T> literal<T>(T value, {String? message}) =>
      VLiteral<T>(value, message: message);

  /// Creates a [VUnion] schema accepting any of the given [options]. See
  /// [string] for [message].
  ///
  /// ```dart
  /// V.union([V.string(), V.int()]);
  /// ```
  static VUnion union(
    List<VType> options, {
    String? message,
  }) =>
      VUnion(options, message: message);
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
  /// Accepts [DateTime] and [String] (ISO 8601) inputs.
  ///
  /// ```dart
  /// V.coerce.date().parse('2024-01-15'); // DateTime(2024, 1, 15)
  /// ```
  VDate date() {
    final schema = VDate();

    schema.coercer = (value) {
      if (value is DateTime) return value;
      if (value is String) return DateTime.parse(value);
      throw FormatException('Cannot coerce $value to DateTime');
    };

    return schema;
  }
}
