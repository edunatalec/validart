import 'package:keeper/src/messages/map_message.dart';
import 'package:keeper/src/types/type.dart';
import 'package:keeper/src/validators/refine_map_validator.dart';
import 'package:keeper/src/validators/required_validator.dart';
import 'package:keeper/src/validators/validator.dart';

class KMap extends KType<Map<String, dynamic>> {
  final Map<String, KType> _object;
  final MapMessage _message;

  KMap(this._object, this._message, {String? message}) {
    assert(_object.isNotEmpty, 'Map must have at least one field.');

    add(RequiredValidator(message: message ?? _message.required));
  }

  @override
  KMap add(KValidator<Map<String, dynamic>> validator) {
    super.add(validator);

    return this;
  }

  @override
  KMap optional() {
    super.optional();

    return this;
  }

  @override
  KMap nullable() {
    super.nullable();

    return this;
  }

  KMap refine(
    bool Function(Map<String, dynamic>? data) validator, {
    required String path,
    String? message,
  }) {
    return add(
      RefineMapValidator(
        validator,
        path: path,
        message: message ?? _message.refine,
      ),
    );
  }

  @override
  Map<String, dynamic>? getErrorMessage(Map<String, dynamic>? value) {
    if (value == null && isNullable) return null;

    final Map<String, dynamic> errors = {};

    for (final validator in validators) {
      final message = validator.validate(value);

      if (message != null) {
        if (validator is RequiredValidator && isOptional && value != null) {
          return null;
        }

        if (validator is RefineMapValidator) {
          errors.addAll({validator.path: message});
        }
      }
    }

    for (final entry in _object.entries) {
      final error = entry.value.getErrorMessage(value?[entry.key]);

      if (error != null) {
        errors.addAll({entry.key: error});
      }
    }

    return errors.isEmpty ? null : errors;
  }
}
