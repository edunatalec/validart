import 'package:keeper/src/types/array.dart';
import 'package:keeper/src/validators/any_validator.dart';
import 'package:keeper/src/validators/every_validator.dart';
import 'package:keeper/src/validators/required_validator.dart';
import 'package:keeper/src/validators/validator.dart';

/// `KType<T>` is an abstract class that serves as the base for all validation types in Keeper.
///
/// This class should be extended by specific types like `KString`, `KInt`, `KBool`, etc.
abstract class KType<T> {
  final List<KValidator<T>> _validators = [];
  bool _isOptional = false;
  bool _isNullable = false;

  /// Returns the list of validators added to this type.
  List<KValidator<T>> get validators => _validators;

  /// Indicates whether the value is optional.
  bool get isOptional => _isOptional;

  /// Indicates whether the value can be null.
  bool get isNullable => _isNullable;

  /// Adds a validator to the current type.
  ///
  /// Example:
  /// ```dart
  /// final validator = k.string().add(MyCustomValidator());
  /// ```
  KType<T> add(KValidator<T> validator) {
    _validators.add(validator);
    return this;
  }

  /// Validates if the value satisfies at least one of the provided types.
  ///
  /// Example:
  /// ```dart
  /// final validator = k.string().any([
  ///   k.string().email(),
  ///   k.string().url(),
  /// ], message: 'Must be an email or URL');
  /// ```
  KType<T> any(List<KType<T>> types, {String? message}) {
    return add(AnyValidator(types, message: message!));
  }

  /// Validates if the value satisfies all of the provided types.
  ///
  /// Example:
  /// ```dart
  /// final validator = k.string().every([
  ///   k.string().min(5),
  ///   k.string().contains('@'),
  /// ], message: 'Must be at least 5 characters and contain @');
  /// ```
  KType<T> every(List<KType<T>> types, {String? message}) {
    return add(EveryValidator(types, message: message!));
  }

  /// Marks the value as optional, allowing it to be omitted.
  ///
  /// Example:
  /// ```dart
  /// final validator = k.string().optional();
  /// ```
  KType<T> optional() {
    _isOptional = true;
    return this;
  }

  /// Marks the value as nullable, allowing it to be `null`.
  ///
  /// Example:
  /// ```dart
  /// final validator = k.string().nullable();
  /// ```
  KType<T> nullable() {
    _isNullable = true;
    return this;
  }

  /// Converts the type into an array validator.
  ///
  /// Example:
  /// ```dart
  /// final validator = k.string().email().array();
  /// print(validator.validate(['test@example.com'])); // true
  /// print(validator.validate(['invalid-email'])); // false
  /// ```
  KArray<T> array() {
    return KArray(this);
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
  /// final validator = k.string().min(5);
  /// print(validator.validate('hello')); // true
  /// print(validator.validate('hi')); // false
  /// ```
  bool validate(T? value) => getErrorMessage(value) == null;
}
