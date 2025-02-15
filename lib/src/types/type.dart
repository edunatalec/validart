import 'package:keeper/src/validators/any_validator.dart';
import 'package:keeper/src/validators/every_validator.dart';
import 'package:keeper/src/validators/required_validator.dart';
import 'package:keeper/src/validators/validator.dart';

abstract class KType<T> {
  final List<KValidator<T>> _validators = [];
  bool _isOptional = false;
  bool _isNullable = false;

  List<KValidator<T>> get validators => _validators;
  bool get isOptional => _isOptional;
  bool get isNullable => _isNullable;

  KType<T> add(KValidator<T> validator) {
    _validators.add(validator);

    return this;
  }

  KType<T> any(List<KType<T>> types, {String? message}) {
    return add(AnyValidator(types, message: message!));
  }

  KType<T> every(List<KType<T>> types, {String? message}) {
    return add(EveryValidator(types, message: message!));
  }

  KType<T> optional() {
    _isOptional = true;

    return this;
  }

  KType<T> nullable() {
    _isNullable = true;

    return this;
  }

  getErrorMessage(T? value) {
    if (value == null && isNullable) return null;

    for (final validator in validators) {
      final message = validator.validate(value);

      if (message != null) {
        if (validator is RequiredValidator && isOptional && value != null) {
          return null;
        }

        return message;
      }
    }

    return null;
  }

  bool validate(T? value) => getErrorMessage(value) == null;
}
