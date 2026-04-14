import 'dart:core' as core;
import 'dart:core';

import 'package:validart/src/types/type.dart';
import 'package:validart/src/v_locale.dart';

class V {
  static VLocale _locale = const VLocale();
  static final VCoerce coerce = VCoerce();

  V._();

  static void setLocale(VLocale locale) => _locale = locale;
  static VLocale get locale => _locale;

  static String t(String code, [Map<String, dynamic> params = const {}]) =>
      _locale.translate(code, params);

  static VString string() => VString();
  static VBool bool() => VBool();
  static VInt int() => VInt();
  static VDouble double() => VDouble();
  static VDate date() => VDate();
  static VMap map(Map<String, VType> schema) => VMap(schema);

  static VObject<T> object<T>({
    void Function(VObjectBuilder<T> o)? configure,
  }) =>
      VObject<T>(configure: configure);

  static VArray<T> array<T>(VType<T> element) => VArray<T>(element);
  static VEnum<T> enm<T extends Enum>(List<T> values) => VEnum<T>(values);
  static VLiteral<T> literal<T>(T value) => VLiteral<T>(value);
  static VUnion union(List<VType> options) => VUnion(options);
}

class VCoerce {
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

  VString string() {
    final schema = VString();
    schema.coercer = (value) => value.toString();

    return schema;
  }

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
