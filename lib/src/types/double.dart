import 'package:validart/src/messages/double_message.dart';
import 'package:validart/src/types/number.dart';
import 'package:validart/src/validators/double/decimal_validator.dart';
import 'package:validart/src/validators/double/finite_validator.dart';
import 'package:validart/src/validators/double/integer_validator.dart';
import 'package:validart/src/validators/required_validator.dart';
import 'package:validart/src/validators/validator.dart';

/// A validator for `double` values, supporting various constraints.
///
/// Example usage:
/// ```dart
/// final v = Validart();
///
/// final validator = v.double().min(10).max(100);
/// print(validator.validate(50.5)); // true
/// print(validator.validate(5.0)); // false
/// ```
class VDouble extends VNumber<double> {
  /// Stores the validation messages for `double`-related errors.
  final DoubleMessage _message;

  /// Creates an instance of `VDouble` with optional custom validation messages.
  ///
  /// By default, it ensures the value is required unless explicitly marked as optional.
  VDouble(this._message, {required String? message}) {
    add(RequiredValidator(message: message ?? _message.required));
  }

  /// Adds a validator to the `VDouble` instance.
  ///
  /// Allows chaining multiple `double` validations.
  @override
  VDouble add(Validator<double> validator) {
    super.add(validator);
    return this;
  }

  /// Validates that the value is greater than or equal to the given `min` value.
  ///
  /// Example:
  /// ```dart
  /// final v = Validart();
  ///
  /// final validator = v.double().min(10);
  /// print(validator.validate(15)); // true
  /// print(validator.validate(5)); // false
  /// ```
  @override
  VDouble min(double min, {String? message}) {
    super.min(min, message: message ?? _message.min(min));
    return this;
  }

  /// Validates that the value is less than or equal to the given `max` value.
  ///
  /// Example:
  /// ```dart
  /// final v = Validart();
  ///
  /// final validator = v.double().max(100);
  /// print(validator.validate(50)); // true
  /// print(validator.validate(150)); // false
  /// ```
  @override
  VDouble max(double max, {String? message}) {
    super.max(max, message: message ?? _message.max(max));
    return this;
  }

  /// Ensures that the value is positive (`> 0`).
  ///
  /// Example:
  /// ```dart
  /// final v = Validart();
  ///
  /// final validator = v.double().positive();
  /// print(validator.validate(5.5)); // true
  /// print(validator.validate(-2.3)); // false
  /// ```
  @override
  VDouble positive({String? message}) {
    super.positive(message: message ?? _message.positive);
    return this;
  }

  /// Ensures that the value is negative (`< 0`).
  ///
  /// Example:
  /// ```dart
  /// final v = Validart();
  ///
  /// final validator = v.double().negative();
  /// print(validator.validate(-5.5)); // true
  /// print(validator.validate(2.3)); // false
  /// ```
  @override
  VDouble negative({String? message}) {
    super.negative(message: message ?? _message.negative);
    return this;
  }

  /// Ensures that the value is within a specified range (`min` to `max`).
  ///
  /// Example:
  /// ```dart
  /// final v = Validart();
  ///
  /// final validator = v.double().between(10, 100);
  /// print(validator.validate(50)); // true
  /// print(validator.validate(5)); // false
  /// ```
  @override
  VDouble between(double min, double max, {String? message}) {
    super.between(min, max, message: message ?? _message.between(min, max));
    return this;
  }

  /// Ensures that the value is a multiple of a given factor.
  ///
  /// Example:
  /// ```dart
  /// final v = Validart();
  ///
  /// final validator = v.double().multipleOf(2.5);
  /// print(validator.validate(5.0)); // true
  /// print(validator.validate(7.5)); // true
  /// print(validator.validate(3.1)); // false
  /// ```
  @override
  VDouble multipleOf(double factor, {String? message}) {
    super.multipleOf(factor, message: message ?? _message.multipleOf(factor));
    return this;
  }

  /// Ensures that the value is a decimal (not an integer).
  ///
  /// Example:
  /// ```dart
  /// final v = Validart();
  ///
  /// final validator = v.double().decimal();
  /// print(validator.validate(3.5)); // true
  /// print(validator.validate(5.0)); // false (integer representation)
  /// ```
  VDouble decimal({String? message}) {
    return add(DecimalValidator(message: message ?? _message.decimal));
  }

  /// Ensures that the value is finite (not `double.infinity` or `double.nan`).
  ///
  /// Example:
  /// ```dart
  /// final v = Validart();
  ///
  /// final validator = v.double().finite();
  /// print(validator.validate(100.0)); // true
  /// print(validator.validate(double.infinity)); // false
  /// print(validator.validate(double.nan)); // false
  /// ```
  VDouble finite({String? message}) {
    return add(FiniteValidator(message: message ?? _message.finite));
  }

  /// Ensures that the value is an integer (no decimal places).
  ///
  /// Example:
  /// ```dart
  /// final v = Validart();
  ///
  /// final validator = v.double().integer();
  /// print(validator.validate(10.0)); // true
  /// print(validator.validate(10.5)); // false
  /// ```
  VDouble integer({String? message}) {
    return add(IntegerValidator(message: message ?? _message.integer));
  }

  /// Validates that the value matches **any** of the provided `VDouble` validators.
  ///
  /// Example:
  /// ```dart
  /// final v = Validart();
  ///
  /// final validator = v.double().any([
  ///   v.double().min(10),
  ///   v.double().max(5)
  /// ]);
  ///
  /// print(validator.validate(12)); // true
  /// print(validator.validate(3)); // true
  /// print(validator.validate(7)); // false
  /// ```
  @override
  VDouble any(covariant List<VDouble> types, {String? message}) {
    super.any(types, message: message ?? _message.any);
    return this;
  }

  /// Ensures that the value meets **all** the specified `double` validation rules.
  ///
  /// Example:
  /// ```dart
  /// final v = Validart();
  ///
  /// final validator = v.double().every([
  ///   v.double().min(10),
  ///   v.double().max(20)
  /// ]);
  ///
  /// print(validator.validate(15)); // true
  /// print(validator.validate(25)); // false
  /// ```
  @override
  VDouble every(covariant List<VDouble> types, {String? message}) {
    super.every(types, message: message ?? _message.every);
    return this;
  }

  /// Marks the value as optional, allowing `null`.
  ///
  /// Example:
  /// ```dart
  /// final v = Validart();
  ///
  /// final validator = v.double().optional();
  /// print(validator.validate(null)); // true
  /// ```
  @override
  VDouble optional() {
    super.optional();
    return this;
  }

  /// Marks the value as nullable, allowing `null`.
  ///
  /// Example:
  /// ```dart
  /// final v = Validart();
  ///
  /// final validator = v.double().nullable();
  /// print(validator.validate(null)); // true
  /// ```
  @override
  VDouble nullable() {
    super.nullable();
    return this;
  }

  /// Applies a custom validation function.
  @override
  VDouble refine(bool Function(double? data) validator, {String? message}) {
    super.refine(validator, message: message ?? _message.refine);
    return this;
  }
}
