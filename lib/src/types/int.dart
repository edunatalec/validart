import 'package:validart/src/messages/int_message.dart';
import 'package:validart/src/types/array.dart';
import 'package:validart/src/types/number.dart';
import 'package:validart/src/validators/int/even_validator.dart';
import 'package:validart/src/validators/int/odd_validator.dart';
import 'package:validart/src/validators/int/prime_validator.dart';
import 'package:validart/src/validators/required_validator.dart';
import 'package:validart/src/validators/validator.dart';

/// A validation class for `int` values in Validart.
///
/// The `VInt` class provides validation rules for integer numbers,
/// including constraints like:
/// - Required validation
/// - Value range (`min`, `max`, `between`)
/// - Numeric properties (`positive`, `negative`, `multipleOf`)
/// - Special conditions (`even`, `odd`, `prime`)
///
/// ## Example Usage:
/// ```dart
/// final validator = v.int().min(10).max(100);
///
/// print(validator.validate(50)); // true
/// print(validator.validate(5)); // false
/// ```
class VInt extends VNumber<int> {
  /// Stores validation messages for `int`-related errors.
  final IntMessage _message;

  /// Creates an instance of `VInt` with optional custom validation messages.
  ///
  /// By default, it ensures the value is required unless explicitly marked as optional.
  VInt(this._message, {required String? message}) {
    add(RequiredValidator(message: message ?? _message.required));
  }

  /// Ensures the value is within a specified range (`min` to `max`).
  ///
  /// Example:
  /// ```dart
  /// final validator = v.int().between(10, 100);
  /// print(validator.validate(50)); // true
  /// print(validator.validate(5)); // false
  /// ```
  @override
  VInt between(int min, int max, {String Function(int min, int max)? message}) {
    super.between(min, max, message: message ?? _message.between);
    return this;
  }

  /// Ensures the value is even.
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

  /// Ensures the value is an integer prime number.
  ///
  /// Example:
  /// ```dart
  /// final validator = v.int().prime();
  /// print(validator.validate(7)); // true
  /// print(validator.validate(10)); // false
  /// ```
  VInt prime({String? message}) {
    return add(PrimeValidator(message: message ?? _message.prime));
  }

  /// Ensures the value is odd.
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

  /// Ensures the value is greater than or equal to `min`.
  ///
  /// Example:
  /// ```dart
  /// final validator = v.int().min(10);
  /// print(validator.validate(15)); // true
  /// print(validator.validate(5)); // false
  /// ```
  @override
  VInt min(int min, {String Function(int min)? message}) {
    super.min(min, message: message ?? _message.min);
    return this;
  }

  /// Ensures the value is less than or equal to `max`.
  ///
  /// Example:
  /// ```dart
  /// final validator = v.int().max(100);
  /// print(validator.validate(50)); // true
  /// print(validator.validate(150)); // false
  /// ```
  @override
  VInt max(int max, {String Function(int)? message}) {
    super.max(max, message: message ?? _message.max);
    return this;
  }

  /// Ensures the value is a multiple of a given factor.
  ///
  /// Example:
  /// ```dart
  /// final validator = v.int().multipleOf(5);
  /// print(validator.validate(10)); // true
  /// print(validator.validate(7)); // false
  /// ```
  @override
  VInt multipleOf(int factor, {String Function(int)? message}) {
    super.multipleOf(factor, message: message ?? _message.multipleOf);
    return this;
  }

  /// Ensures the value is positive (`> 0`).
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

  /// Ensures the value is negative (`< 0`).
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

  /// Adds a validator to the `VInt` instance.
  ///
  /// Allows chaining multiple `int` validations.
  @override
  VInt add(Validator<int> validator) {
    super.add(validator);
    return this;
  }

  /// Ensures the value matches **any** of the provided `VInt` validators.
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

  /// Ensures the value passes **all** of the specified `int` validation rules.
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

  /// Marks the value as optional, allowing it to be omitted but not `null`.
  ///
  /// Example:
  /// ```dart
  /// final validator = v.int().optional();
  /// print(validator.validate(5)); // true
  /// print(validator.validate(null)); // false
  /// ```
  @override
  VInt optional() {
    super.optional();
    return this;
  }

  /// Marks the value as nullable, allowing `null` values.
  ///
  /// Example:
  /// ```dart
  /// final validator = v.int().nullable();
  /// print(validator.validate(null)); // true
  /// print(validator.validate(5)); // true
  /// ```
  @override
  VInt nullable() {
    super.nullable();
    return this;
  }

  /// Applies a custom validation rule.
  ///
  /// Example:
  /// ```dart
  /// final validator = v.int().refine((value) => value % 2 == 0);
  /// print(validator.validate(4)); // true
  /// print(validator.validate(5)); // false
  /// ```
  @override
  VInt refine(bool Function(int data) validator, {String? message}) {
    super.refine(validator, message: message ?? _message.refine);
    return this;
  }

  /// Validates an array of integer values.
  ///
  /// Example:
  /// ```dart
  /// final validator = v.int().array();
  ///
  /// print(validator.validate([1, 2, 3])); // true
  /// print(validator.validate([1, 'invalid', 3])); // false
  /// ```
  @override
  VArray<int> array({String? message}) {
    return VArray<int>(this, _message.array, message: message);
  }
}
