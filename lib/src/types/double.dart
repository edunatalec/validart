import 'package:keeper/src/messages/double_message.dart';
import 'package:keeper/src/types/number.dart';
import 'package:keeper/src/validators/double/decimal_validator.dart';
import 'package:keeper/src/validators/double/finite_validator.dart';
import 'package:keeper/src/validators/double/integer_validator.dart';
import 'package:keeper/src/validators/required_validator.dart';
import 'package:keeper/src/validators/validator.dart';

/// A validator for `double` values, supporting various constraints.
///
/// Example usage:
/// ```dart
/// final k = Keeper();
///
/// final validator = k.double().min(10).max(100);
/// print(validator.validate(50.5)); // true
/// print(validator.validate(5.0)); // false
/// ```
class KDouble extends KNumber<double> {
  /// Stores the validation messages for `double`-related errors.
  final DoubleMessage _message;

  /// Creates an instance of `KDouble` with optional custom validation messages.
  ///
  /// By default, it ensures the value is required unless explicitly marked as optional.
  KDouble(this._message, {required String? message}) {
    add(RequiredValidator(message: message ?? _message.required));
  }

  /// Adds a validator to the `KDouble` instance.
  ///
  /// Allows chaining multiple `double` validations.
  @override
  KDouble add(KValidator<double> validator) {
    super.add(validator);
    return this;
  }

  /// Validates that the value is greater than or equal to the given `min` value.
  ///
  /// Example:
  /// ```dart
  /// final k = Keeper();
  ///
  /// final validator = k.double().min(10);
  /// print(validator.validate(15)); // true
  /// print(validator.validate(5)); // false
  /// ```
  @override
  KDouble min(double min, {String? message}) {
    super.min(min, message: message ?? _message.min(min));
    return this;
  }

  /// Validates that the value is less than or equal to the given `max` value.
  ///
  /// Example:
  /// ```dart
  /// final k = Keeper();
  ///
  /// final validator = k.double().max(100);
  /// print(validator.validate(50)); // true
  /// print(validator.validate(150)); // false
  /// ```
  @override
  KDouble max(double max, {String? message}) {
    super.max(max, message: message ?? _message.max(max));
    return this;
  }

  /// Ensures that the value is positive (`> 0`).
  ///
  /// Example:
  /// ```dart
  /// final k = Keeper();
  ///
  /// final validator = k.double().positive();
  /// print(validator.validate(5.5)); // true
  /// print(validator.validate(-2.3)); // false
  /// ```
  @override
  KDouble positive({String? message}) {
    super.positive(message: message ?? _message.positive);
    return this;
  }

  /// Ensures that the value is negative (`< 0`).
  ///
  /// Example:
  /// ```dart
  /// final k = Keeper();
  ///
  /// final validator = k.double().negative();
  /// print(validator.validate(-5.5)); // true
  /// print(validator.validate(2.3)); // false
  /// ```
  @override
  KDouble negative({String? message}) {
    super.negative(message: message ?? _message.negative);
    return this;
  }

  /// Ensures that the value is within a specified range (`min` to `max`).
  ///
  /// Example:
  /// ```dart
  /// final k = Keeper();
  ///
  /// final validator = k.double().between(10, 100);
  /// print(validator.validate(50)); // true
  /// print(validator.validate(5)); // false
  /// ```
  @override
  KDouble between(double min, double max, {String? message}) {
    super.between(min, max, message: message ?? _message.between(min, max));
    return this;
  }

  /// Ensures that the value is a multiple of a given factor.
  ///
  /// Example:
  /// ```dart
  /// final k = Keeper();
  ///
  /// final validator = k.double().multipleOf(2.5);
  /// print(validator.validate(5.0)); // true
  /// print(validator.validate(7.5)); // true
  /// print(validator.validate(3.1)); // false
  /// ```
  @override
  KDouble multipleOf(double factor, {String? message}) {
    super.multipleOf(factor, message: message ?? _message.multipleOf(factor));
    return this;
  }

  /// Ensures that the value is a decimal (not an integer).
  ///
  /// Example:
  /// ```dart
  /// final k = Keeper();
  ///
  /// final validator = k.double().decimal();
  /// print(validator.validate(3.5)); // true
  /// print(validator.validate(5.0)); // false (integer representation)
  /// ```
  KDouble decimal({String? message}) {
    return add(DecimalValidator(message: message ?? _message.decimal));
  }

  /// Ensures that the value is finite (not `double.infinity` or `double.nan`).
  ///
  /// Example:
  /// ```dart
  /// final k = Keeper();
  ///
  /// final validator = k.double().finite();
  /// print(validator.validate(100.0)); // true
  /// print(validator.validate(double.infinity)); // false
  /// print(validator.validate(double.nan)); // false
  /// ```
  KDouble finite({String? message}) {
    return add(FiniteValidator(message: message ?? _message.finite));
  }

  /// Ensures that the value is an integer (no decimal places).
  ///
  /// Example:
  /// ```dart
  /// final k = Keeper();
  ///
  /// final validator = k.double().integer();
  /// print(validator.validate(10.0)); // true
  /// print(validator.validate(10.5)); // false
  /// ```
  KDouble integer({String? message}) {
    return add(IntegerValidator(message: message ?? _message.integer));
  }

  /// Validates that the value matches **any** of the provided `KDouble` validators.
  ///
  /// Example:
  /// ```dart
  /// final k = Keeper();
  ///
  /// final validator = k.double().any([
  ///   k.double().min(10),
  ///   k.double().max(5)
  /// ]);
  ///
  /// print(validator.validate(12)); // true
  /// print(validator.validate(3)); // true
  /// print(validator.validate(7)); // false
  /// ```
  @override
  KDouble any(covariant List<KDouble> types, {String? message}) {
    super.any(types, message: message ?? _message.any);
    return this;
  }

  /// Ensures that the value meets **all** the specified `double` validation rules.
  ///
  /// Example:
  /// ```dart
  /// final k = Keeper();
  ///
  /// final validator = k.double().every([
  ///   k.double().min(10),
  ///   k.double().max(20)
  /// ]);
  ///
  /// print(validator.validate(15)); // true
  /// print(validator.validate(25)); // false
  /// ```
  @override
  KDouble every(covariant List<KDouble> types, {String? message}) {
    super.every(types, message: message ?? _message.every);
    return this;
  }

  /// Marks the value as optional, allowing `null`.
  ///
  /// Example:
  /// ```dart
  /// final k = Keeper();
  ///
  /// final validator = k.double().optional();
  /// print(validator.validate(null)); // true
  /// ```
  @override
  KDouble optional() {
    super.optional();
    return this;
  }

  /// Marks the value as nullable, allowing `null`.
  ///
  /// Example:
  /// ```dart
  /// final k = Keeper();
  ///
  /// final validator = k.double().nullable();
  /// print(validator.validate(null)); // true
  /// ```
  @override
  KDouble nullable() {
    super.nullable();
    return this;
  }

  /// Applies a custom validation function.
  @override
  KDouble refine(bool Function(double? data) validator, {String? message}) {
    super.refine(validator, message: message ?? _message.refine);
    return this;
  }
}
