import 'package:validart/src/types/array.dart';
import 'package:validart/src/validators/any_validator.dart';
import 'package:validart/src/validators/every_validator.dart';
import 'package:validart/src/validators/required_validator.dart';
import 'package:validart/src/validators/validator.dart';

/// `VType<T>` is an abstract class that serves as the base for all validation types in Validart.
///
/// This class should be extended by specific types like `VString`, `VInt`, `VBool`, etc.
abstract class VType<T> {
  final List<Validator<T>> _validators = [];
  bool _isOptional = false;
  bool _isNullable = false;

  /// Returns the list of validators added to this type.
  List<Validator<T>> get validators => _validators;

  /// Indicates whether the value is optional.
  bool get isOptional => _isOptional;

  /// Indicates whether the value can be null.
  bool get isNullable => _isNullable;

  /// Adds a validator to the current type.
  ///
  /// Example:
  /// ```dart
  /// final validator = v.string().add(MyCustomValidator());
  /// ```
  VType<T> add(Validator<T> validator) {
    _validators.add(validator);
    return this;
  }

  /// Validates if the value satisfies at least one of the provided types.
  ///
  /// Example:
  /// ```dart
  /// final validator = v.string().any([
  ///   v.string().email(),
  ///   v.string().url(),
  /// ], message: 'Must be an email or URL');
  /// ```
  VType<T> any(List<VType<T>> types, {String? message}) {
    return add(AnyValidator(types, message: message!));
  }

  /// Validates if the value satisfies all of the provided types.
  ///
  /// Example:
  /// ```dart
  /// final validator = v.string().every([
  ///   v.string().min(5),
  ///   v.string().contains('@'),
  /// ], message: 'Must be at least 5 characters and contain @');
  /// ```
  VType<T> every(List<VType<T>> types, {String? message}) {
    return add(EveryValidator(types, message: message!));
  }

  /// Marks the value as optional, allowing it to be omitted.
  ///
  /// Example:
  /// ```dart
  /// final validator = v.string().optional();
  /// ```
  VType<T> optional() {
    _isOptional = true;
    return this;
  }

  /// Marks the value as nullable, allowing it to be `null`.
  ///
  /// Example:
  /// ```dart
  /// final validator = v.string().nullable();
  /// ```
  VType<T> nullable() {
    _isNullable = true;
    return this;
  }

  /// Converts the type into an array validator.
  ///
  /// Example:
  /// ```dart
  /// final validator = v.string().email().array();
  /// print(validator.validate(['test@example.com'])); // true
  /// print(validator.validate(['invalid-email'])); // false
  /// ```
  VArray<T> array() {
    return VArray(this);
  }

  /// Retrieves the error message for the given value.
  ///
  /// If the value is valid, it returns `null`. Otherwise, it returns the validation error message.
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

  /// Validates the value and returns `true` if it passes all checks, otherwise `false`.
  ///
  /// Example:
  /// ```dart
  /// final validator = v.string().min(5);
  /// print(validator.validate('hello')); // true
  /// print(validator.validate('hi')); // false
  /// ```
  bool validate(T? value) => getErrorMessage(value) == null;
}
