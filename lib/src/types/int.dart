import 'package:keeper/src/messages/int_message.dart';
import 'package:keeper/src/types/number.dart';
import 'package:keeper/src/validators/int/even_validator.dart';
import 'package:keeper/src/validators/int/odd_validator.dart';
import 'package:keeper/src/validators/required_validator.dart';
import 'package:keeper/src/validators/validator.dart';

/// A validator for `int` values, supporting various constraints.
///
/// Example usage:
/// ```dart
/// final k = Keeper();
///
/// final validator = k.int().min(10).max(100);
/// print(validator.validate(50)); // true
/// print(validator.validate(5)); // false
/// ```
class KInt extends KNumber<int> {
  /// Stores the validation messages for `int`-related errors.
  final IntMessage _message;

  /// Creates an instance of `KInt` with optional custom validation messages.
  ///
  /// By default, it ensures the value is required unless explicitly marked as optional.
  KInt(this._message, {required String? message}) {
    add(RequiredValidator(message: message ?? _message.required));
  }

  /// Adds a validator to the `KInt` instance.
  ///
  /// Allows chaining multiple `int` validations.
  @override
  KInt add(KValidator<int> validator) {
    super.add(validator);
    return this;
  }

  /// Validates that the value is greater than or equal to the given `min` value.
  ///
  /// Example:
  /// ```dart
  /// final validator = k.int().min(10);
  /// print(validator.validate(15)); // true
  /// print(validator.validate(5)); // false
  /// ```
  @override
  KInt min(int min, {String? message}) {
    super.min(min, message: message ?? _message.min(min));
    return this;
  }

  /// Validates that the value is less than or equal to the given `max` value.
  ///
  /// Example:
  /// ```dart
  /// final validator = k.int().max(100);
  /// print(validator.validate(50)); // true
  /// print(validator.validate(150)); // false
  /// ```
  @override
  KInt max(int max, {String? message}) {
    super.max(max, message: message ?? _message.max(max));
    return this;
  }

  /// Ensures that the value is positive (`> 0`).
  ///
  /// Example:
  /// ```dart
  /// final validator = k.int().positive();
  /// print(validator.validate(5)); // true
  /// print(validator.validate(-2)); // false
  /// ```
  @override
  KInt positive({String? message}) {
    super.positive(message: message ?? _message.positive);
    return this;
  }

  /// Ensures that the value is negative (`< 0`).
  ///
  /// Example:
  /// ```dart
  /// final validator = k.int().negative();
  /// print(validator.validate(-5)); // true
  /// print(validator.validate(2)); // false
  /// ```
  @override
  KInt negative({String? message}) {
    super.negative(message: message ?? _message.negative);
    return this;
  }

  /// Ensures that the value is within a specified range (`min` to `max`).
  ///
  /// Example:
  /// ```dart
  /// final validator = k.int().between(10, 100);
  /// print(validator.validate(50)); // true
  /// print(validator.validate(5)); // false
  /// ```
  @override
  KInt between(int min, int max, {String? message}) {
    super.between(min, max, message: message ?? _message.between(min, max));
    return this;
  }

  /// Ensures that the value is a multiple of a given factor.
  ///
  /// Example:
  /// ```dart
  /// final validator = k.int().multipleOf(5);
  /// print(validator.validate(10)); // true
  /// print(validator.validate(7)); // false
  /// ```
  @override
  KInt multipleOf(int factor, {String? message}) {
    super.multipleOf(factor, message: message ?? _message.multipleOf(factor));
    return this;
  }

  /// Ensures that the value is even.
  ///
  /// Example:
  /// ```dart
  /// final validator = k.int().even();
  /// print(validator.validate(4)); // true
  /// print(validator.validate(5)); // false
  /// ```
  KInt even({String? message}) {
    return add(EvenValidator(message: message ?? _message.even));
  }

  /// Ensures that the value is odd.
  ///
  /// Example:
  /// ```dart
  /// final validator = k.int().odd();
  /// print(validator.validate(5)); // true
  /// print(validator.validate(4)); // false
  /// ```
  KInt odd({String? message}) {
    return add(OddValidator(message: message ?? _message.odd));
  }

  /// Validates that the value matches **any** of the provided `KInt` validators.
  ///
  /// Example:
  /// ```dart
  /// final validator = k.int().any([
  ///   k.int().min(10),
  ///   k.int().max(5)
  /// ]);
  ///
  /// print(validator.validate(12)); // true
  /// print(validator.validate(3)); // true
  /// print(validator.validate(7)); // false
  /// ```
  @override
  KInt any(covariant List<KInt> types, {String? message}) {
    super.any(types, message: message ?? _message.any);
    return this;
  }

  /// Ensures that the value meets **all** the specified `int` validation rules.
  ///
  /// Example:
  /// ```dart
  /// final validator = k.int().every([
  ///   k.int().min(10),
  ///   k.int().max(20)
  /// ]);
  ///
  /// print(validator.validate(15)); // true
  /// print(validator.validate(25)); // false
  /// ```
  @override
  KInt every(covariant List<KInt> types, {String? message}) {
    super.every(types, message: message ?? _message.every);
    return this;
  }

  /// Marks the value as optional, allowing `null`.
  ///
  /// Example:
  /// ```dart
  /// final validator = k.int().optional();
  /// print(validator.validate(null)); // true
  /// ```
  @override
  KInt optional() {
    super.optional();
    return this;
  }

  /// Marks the value as nullable, allowing `null`.
  ///
  /// Example:
  /// ```dart
  /// final validator = k.int().nullable();
  /// print(validator.validate(null)); // true
  /// ```
  @override
  KInt nullable() {
    super.nullable();
    return this;
  }

  /// Applies a custom validation function.
  ///
  /// Example:
  /// ```dart
  /// final validator = k.int().refine((value) => value! % 2 == 0);
  /// print(validator.validate(4)); // true
  /// print(validator.validate(5)); // false
  /// ```
  @override
  KInt refine(bool Function(int? data) validator, {String? message}) {
    super.refine(validator, message: message ?? _message.refine);
    return this;
  }
}
