import 'package:validart/src/messages/num_message.dart';
import 'package:validart/src/types/number.dart';
import 'package:validart/src/validators/required_validator.dart';
import 'package:validart/src/validators/validator.dart';

/// A validator for `num` values, supporting various constraints.
///
/// `VNum` is used to validate both integers and floating-point numbers,
/// allowing constraints like minimum/maximum values, positivity, negativity, and divisibility.
///
/// Example usage:
/// ```dart
/// final v = Validart();
///
/// final validator = v.num().min(5).max(10).multipleOf(2);
///
/// print(validator.validate(6)); // true
/// print(validator.validate(3)); // false
/// print(validator.validate(11)); // false
/// ```
class VNum extends VNumber<num> {
  /// Stores the validation messages for `num`-related errors.
  final NumMessage _message;

  /// Creates an instance of `VNum` with optional custom messages.
  VNum(this._message, {required String? message}) {
    add(RequiredValidator(message: message ?? _message.required));
  }

  /// Adds a validator to the `VNum` instance.
  ///
  /// This allows chaining multiple validation rules.
  @override
  VNum add(Validator<num> validator) {
    super.add(validator);
    return this;
  }

  /// Sets a minimum value constraint.
  ///
  /// Example:
  /// ```dart
  /// final validator = v.num().min(10);
  /// print(validator.validate(9)); // false
  /// print(validator.validate(10)); // true
  /// ```
  @override
  VNum min(num min, {String? message}) {
    super.min(min, message: message ?? _message.min(min));
    return this;
  }

  /// Sets a maximum value constraint.
  ///
  /// Example:
  /// ```dart
  /// final validator = v.num().max(100);
  /// print(validator.validate(101)); // false
  /// print(validator.validate(99)); // true
  /// ```
  @override
  VNum max(num max, {String? message}) {
    super.max(max, message: message ?? _message.max(max));
    return this;
  }

  /// Ensures the number is positive.
  ///
  /// Example:
  /// ```dart
  /// final validator = v.num().positive();
  /// print(validator.validate(-5)); // false
  /// print(validator.validate(3)); // true
  /// ```
  @override
  VNum positive({String? message}) {
    super.positive(message: message ?? _message.positive);
    return this;
  }

  /// Ensures the number is negative.
  ///
  /// Example:
  /// ```dart
  /// final validator = v.num().negative();
  /// print(validator.validate(5)); // false
  /// print(validator.validate(-3)); // true
  /// ```
  @override
  VNum negative({String? message}) {
    super.negative(message: message ?? _message.negative);
    return this;
  }

  /// Ensures the number falls within a range (inclusive).
  ///
  /// Example:
  /// ```dart
  /// final validator = v.num().between(10, 20);
  /// print(validator.validate(9)); // false
  /// print(validator.validate(15)); // true
  /// print(validator.validate(21)); // false
  /// ```
  @override
  VNum between(num min, num max, {String? message}) {
    super.between(min, max, message: message ?? _message.between(min, max));
    return this;
  }

  /// Ensures the number is a multiple of a given value.
  ///
  /// Example:
  /// ```dart
  /// final validator = v.num().multipleOf(5);
  /// print(validator.validate(10)); // true
  /// print(validator.validate(7)); // false
  /// ```
  @override
  VNum multipleOf(num factor, {String? message}) {
    super.multipleOf(factor, message: message ?? _message.multipleOf(factor));
    return this;
  }

  /// Validates that the value matches **any** of the provided `VNum` validators.
  ///
  /// Example:
  /// ```dart
  /// final validator = v.num().any([
  ///   v.num().positive(),
  ///   v.num().multipleOf(5),
  /// ]);
  ///
  /// print(validator.validate(10)); // true (multiple of 5)
  /// print(validator.validate(-3)); // false (not positive, not multiple of 5)
  /// print(validator.validate(7)); // false
  /// ```
  @override
  VNum any(covariant List<VNum> types, {String? message}) {
    super.any(types, message: message ?? _message.any);
    return this;
  }

  /// Ensures that the value meets **all** specified validation rules.
  ///
  /// Example:
  /// ```dart
  /// final validator = v.num().every([
  ///   v.num().positive(),
  ///   v.num().between(1, 100),
  /// ]);
  ///
  /// print(validator.validate(50)); // true (positive and between 1-100)
  /// print(validator.validate(-10)); // false (not positive)
  /// print(validator.validate(150)); // false (out of range)
  /// ```
  @override
  VNum every(covariant List<VNum> types, {String? message}) {
    super.every(types, message: message ?? _message.every);
    return this;
  }

  /// Marks the value as optional, allowing it to be omitted.
  ///
  /// Example:
  /// ```dart
  /// final validator = v.num().optional();
  /// print(validator.validate(null)); // true
  /// ```
  @override
  VNum optional() {
    super.optional();
    return this;
  }

  /// Marks the value as nullable, allowing it to be `null`.
  ///
  /// Example:
  /// ```dart
  /// final validator = v.num().nullable();
  /// print(validator.validate(null)); // true
  /// ```
  @override
  VNum nullable() {
    super.nullable();
    return this;
  }

  /// Applies a custom validation function.
  ///
  /// Example (custom refinement):
  /// ```dart
  /// final validator = v.num().refine(
  ///   (value) => value != null && value % 2 == 0,
  ///   message: 'The number must be even',
  /// );
  ///
  /// print(validator.validate(4)); // true
  /// print(validator.validate(7)); // false
  /// ```
  @override
  VNum refine(bool Function(num? data) validator, {String? message}) {
    super.refine(validator, message: message ?? _message.refine);
    return this;
  }
}
