import 'dart:core' as core;
import 'dart:core';

import 'package:validart/src/messages/messages.dart';
import 'package:validart/src/types/type.dart';

class Validart {
  final VMessages _messages;
  late final VCoerce coerce;

  Validart({VMessages messages = const VMessages()}) : _messages = messages {
    coerce = VCoerce(_messages);
  }

  VString string() => VString(_messages.string);

  VBool bool() => VBool(_messages.bool);

  VInt int() => VInt(_messages.number);

  VDouble double() => VDouble(_messages.number);

  VDate date() => VDate(_messages.date);

  VMap map(Map<String, VType> schema) => VMap(schema);

  VObject<T> object<T>([void Function(VObjectBuilder<T> o)? configure]) {
    return VObject<T>(configure);
  }

  VArray<T> array<T>(VType<T> element) {
    return VArray<T>(element, _messages.array);
  }

  VEnum<T> enm<T extends Enum>(List<T> values) => VEnum<T>(values);

  VLiteral<T> literal<T>(T value) => VLiteral<T>(value);

  VUnion union(List<VType> options) => VUnion(options);
}

class VCoerce {
  final VMessages _messages;

  VCoerce(this._messages);

  VInt int() {
    final schema = VInt(_messages.number);
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
    final schema = VDouble(_messages.number);
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
    final schema = VString(_messages.string);
    schema.coercer = (value) => value.toString();
    return schema;
  }

  VBool bool() {
    final schema = VBool(_messages.bool);
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
    final schema = VDate(_messages.date);
    schema.coercer = (value) {
      if (value is DateTime) return value;
      if (value is String) return DateTime.parse(value);
      throw FormatException('Cannot coerce $value to DateTime');
    };
    return schema;
  }
}
