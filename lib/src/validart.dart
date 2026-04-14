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

  VString string() => VString(
        messages: _messages.string,
        requiredMessage: _messages.required,
        invalidTypeMessage: _messages.invalidType,
      );

  VBool bool() => VBool(
        messages: _messages.bool,
        requiredMessage: _messages.required,
        invalidTypeMessage: _messages.invalidType,
      );

  VInt int() => VInt(
        messages: _messages.number,
        requiredMessage: _messages.required,
        invalidTypeMessage: _messages.invalidType,
      );

  VDouble double() => VDouble(
        messages: _messages.number,
        requiredMessage: _messages.required,
        invalidTypeMessage: _messages.invalidType,
      );

  VDate date() => VDate(
        messages: _messages.date,
        requiredMessage: _messages.required,
        invalidTypeMessage: _messages.invalidType,
      );

  VMap map(Map<String, VType> schema) => VMap(
        schema,
        requiredMessage: _messages.required,
        invalidTypeMessage: _messages.invalidType,
      );

  VObject<T> object<T>({void Function(VObjectBuilder<T> o)? configure}) {
    return VObject<T>(
      configure: configure,
      requiredMessage: _messages.required,
      invalidTypeMessage: _messages.invalidType,
    );
  }

  VArray<T> array<T>(VType<T> element) {
    return VArray<T>(
      element,
      messages: _messages.array,
      requiredMessage: _messages.required,
      invalidTypeMessage: _messages.invalidType,
    );
  }

  VEnum<T> enm<T extends Enum>(List<T> values) => VEnum<T>(
        values,
        requiredMessage: _messages.required,
        invalidTypeMessage: _messages.invalidType,
      );

  VLiteral<T> literal<T>(T value) => VLiteral<T>(
        value,
        requiredMessage: _messages.required,
        invalidTypeMessage: _messages.invalidType,
      );

  VUnion union(List<VType> options) => VUnion(
        options,
        requiredMessage: _messages.required,
        invalidTypeMessage: _messages.invalidType,
      );
}

class VCoerce {
  final VMessages _messages;

  VCoerce(this._messages);

  VInt int() {
    final schema = VInt(
      messages: _messages.number,
      requiredMessage: _messages.required,
      invalidTypeMessage: _messages.invalidType,
    );
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
    final schema = VDouble(
      messages: _messages.number,
      requiredMessage: _messages.required,
      invalidTypeMessage: _messages.invalidType,
    );
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
    final schema = VString(
      messages: _messages.string,
      requiredMessage: _messages.required,
      invalidTypeMessage: _messages.invalidType,
    );
    schema.coercer = (value) => value.toString();
    return schema;
  }

  VBool bool() {
    final schema = VBool(
      messages: _messages.bool,
      requiredMessage: _messages.required,
      invalidTypeMessage: _messages.invalidType,
    );
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
    final schema = VDate(
      messages: _messages.date,
      requiredMessage: _messages.required,
      invalidTypeMessage: _messages.invalidType,
    );
    schema.coercer = (value) {
      if (value is DateTime) return value;
      if (value is String) return DateTime.parse(value);
      throw FormatException('Cannot coerce $value to DateTime');
    };
    return schema;
  }
}
