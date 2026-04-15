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
class V {
  static VLocale _locale = const VLocale();
  /// Provides coercion schemas that convert input values before validation.
  static final VCoerce coerce = VCoerce();

  V._();

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
  /// ```dart
  /// V.string().email().min(5);
  /// ```
  static VString string() => VString();

  /// Creates a [VBool] schema.
  ///
  /// ```dart
  /// V.bool().isTrue();
  /// ```
  static VBool bool() => VBool();

  /// Creates a [VInt] schema.
  ///
  /// ```dart
  /// V.int().positive().min(1);
  /// ```
  static VInt int() => VInt();

  /// Creates a [VDouble] schema.
  ///
  /// ```dart
  /// V.double().finite().positive();
  /// ```
  static VDouble double() => VDouble();

  /// Creates a [VDate] schema.
  ///
  /// ```dart
  /// V.date().after(DateTime(2024));
  /// ```
  static VDate date() => VDate();

  /// Creates a [VMap] schema with the given field [schema].
  ///
  /// ```dart
  /// V.map({'name': V.string(), 'age': V.int()});
  /// ```
  static VMap map(Map<String, VType> schema) => VMap(schema);

  /// Creates a [VObject] schema for type-safe entity validation.
  ///
  /// ```dart
  /// V.object<User>(configure: (o) {
  ///   o.field('name', (u) => u.name, V.string());
  /// });
  /// ```
  static VObject<T> object<T>({
    void Function(VObjectBuilder<T> o)? configure,
  }) =>
      VObject<T>(configure: configure);

  /// Creates a [VArray] schema for the given [element] type.
  ///
  /// ```dart
  /// V.array(V.string().email());
  /// ```
  static VArray<T> array<T>(VType<T> element) => VArray<T>(element);

  /// Creates a [VEnum] schema accepting the given enum [values].
  ///
  /// ```dart
  /// V.enm(Color.values);
  /// ```
  static VEnum<T> enm<T extends Enum>(List<T> values) => VEnum<T>(values);

  /// Creates a [VLiteral] schema accepting only the given [value].
  ///
  /// ```dart
  /// V.literal('active');
  /// ```
  static VLiteral<T> literal<T>(T value) => VLiteral<T>(value);

  /// Creates a [VUnion] schema accepting any of the given [options].
  ///
  /// ```dart
  /// V.union([V.string(), V.int()]);
  /// ```
  static VUnion union(List<VType> options) => VUnion(options);
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
