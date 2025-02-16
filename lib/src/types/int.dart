import 'package:validart/src/messages/int_message.dart';
import 'package:validart/src/types/number.dart';
import 'package:validart/src/validators/int/even_validator.dart';
import 'package:validart/src/validators/int/odd_validator.dart';
import 'package:validart/src/validators/required_validator.dart';
import 'package:validart/src/validators/validator.dart';

/// A validator for `int` values, supporting various constraints.
///
/// Example usage:
/// ```dart
/// final v = Validart();
///
/// final validator = v.int().min(10).max(100);
/// print(validator.validate(50)); // true
/// print(validator.validate(5)); // false
/// ```
class VInt extends VNumber<int> {
  /// Stores the validation messages for `int`-related errors.
  final IntMessage _message;

  /// Creates an instance of `VInt` with optional custom validation messages.
  ///
  /// By default, it ensures the value is required unless explicitly marked as optional.
  VInt(this._message, {required String? message}) {
    add(RequiredValidator(message: message ?? _message.required));
  }

  /// Adds a validator to the `VInt` instance.
  ///
  /// Allows chaining multiple `int` validations.
  @override
  VInt add(Validator<int> validator) {
    super.add(validator);
    return this;
  }

  /// Validates that the value is greater than or equal to the given `min` value.
  ///
  /// Example:
  /// ```dart
  /// final validator = v.int().min(10);
  /// print(validator.validate(15)); // true
  /// print(validator.validate(5)); // false
  /// ```
  @override
  VInt min(int min, {String? message}) {
    super.min(min, message: message ?? _message.min(min));
    return this;
  }

  /// Validates that the value is less than or equal to the given `max` value.
  ///
  /// Example:
  /// ```dart
  /// final validator = v.int().max(100);
  /// print(validator.validate(50)); // true
  /// print(validator.validate(150)); // false
  /// ```
  @override
  VInt max(int max, {String? message}) {
    super.max(max, message: message ?? _message.max(max));
    return this;
  }

  /// Ensures that the value is positive (`> 0`).
  ///
  /// Example:
  /// ```dart
  /// final validator = v.int().positive();
  /// print(validator.validate(5)); // true
  /// print(validator.validate(-2)); // false
  /// ```
  @override
  VInt positive({String? message}) {
    super.positive(message: message ?? _message.positive);
    return this;
  }

  /// Ensures that the value is negative (`< 0`).
  ///
  /// Example:
  /// ```dart
  /// final validator = v.int().negative();
  /// print(validator.validate(-5)); // true
  /// print(validator.validate(2)); // false
  /// ```
  @override
  VInt negative({String? message}) {
    super.negative(message: message ?? _message.negative);
    return this;
  }

  /// Ensures that the value is within a specified range (`min` to `max`).
  ///
  /// Example:
  /// ```dart
  /// final validator = v.int().between(10, 100);
  /// print(validator.validate(50)); // true
  /// print(validator.validate(5)); // false
  /// ```
  @override
  VInt between(int min, int max, {String? message}) {
    super.between(min, max, message: message ?? _message.between(min, max));
    return this;
  }

  /// Ensures that the value is a multiple of a given factor.
  ///
  /// Example:
  /// ```dart
  /// final validator = v.int().multipleOf(5);
  /// print(validator.validate(10)); // true
  /// print(validator.validate(7)); // false
  /// ```
  @override
  VInt multipleOf(int factor, {String? message}) {
    super.multipleOf(factor, message: message ?? _message.multipleOf(factor));
    return this;
  }

  /// Ensures that the value is even.
  ///
  /// Example:
  /// ```dart
  /// final validator = v.int().even();
  /// print(validator.validate(4)); // true
  /// print(validator.validate(5)); // false
  /// ```
  VInt even({String? message}) {
    return add(EvenValidator(message: message ?? _message.even));
  }

  /// Ensures that the value is odd.
  ///
  /// Example:
  /// ```dart
  /// final validator = v.int().odd();
  /// print(validator.validate(5)); // true
  /// print(validator.validate(4)); // false
  /// ```
  VInt odd({String? message}) {
    return add(OddValidator(message: message ?? _message.odd));
  }

  /// Validates that the value matches **any** of the provided `VInt` validators.
  ///
  /// Example:
  /// ```dart
  /// final validator = v.int().any([
  ///   v.int().min(10),
  ///   v.int().max(5)
  /// ]);
  ///
  /// print(validator.validate(12)); // true
  /// print(validator.validate(3)); // true
  /// print(validator.validate(7)); // false
  /// ```
  @override
  VInt any(covariant List<VInt> types, {String? message}) {
    super.any(types, message: message ?? _message.any);
    return this;
  }

  /// Ensures that the value meets **all** the specified `int` validation rules.
  ///
  /// Example:
  /// ```dart
  /// final validator = v.int().every([
  ///   v.int().min(10),
  ///   v.int().max(20)
  /// ]);
  ///
  /// print(validator.validate(15)); // true
  /// print(validator.validate(25)); // false
  /// ```
  @override
  VInt every(covariant List<VInt> types, {String? message}) {
    super.every(types, message: message ?? _message.every);
    return this;
  }

  /// Marks the value as optional, allowing `null`.
  ///
  /// Example:
  /// ```dart
  /// final validator = v.int().optional();
  /// print(validator.validate(null)); // true
  /// ```
  @override
  VInt optional() {
    super.optional();
    return this;
  }

  /// Marks the value as nullable, allowing `null`.
  ///
  /// Example:
  /// ```dart
  /// final validator = v.int().nullable();
  /// print(validator.validate(null)); // true
  /// ```
  @override
  VInt nullable() {
    super.nullable();
    return this;
  }

  /// Applies a custom validation function.
  ///
  /// Example:
  /// ```dart
  /// final validator = v.int().refine((value) => value! % 2 == 0);
  /// print(validator.validate(4)); // true
  /// print(validator.validate(5)); // false
  /// ```
  @override
  VInt refine(bool Function(int? data) validator, {String? message}) {
    super.refine(validator, message: message ?? _message.refine);
    return this;
  }
}
