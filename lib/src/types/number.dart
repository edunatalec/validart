import 'package:validart/src/types/refine.dart';
import 'package:validart/src/validators/num/between_validator.dart';
import 'package:validart/src/validators/num/max_validator.dart';
import 'package:validart/src/validators/num/min_validator.dart';
import 'package:validart/src/validators/num/multiple_of_validator.dart';
import 'package:validart/src/validators/num/negative_validator.dart';
import 'package:validart/src/validators/num/positive_validator.dart';

/// A base class for validating numerical values (`int`, `double`, and `num`).
///
/// Example usage:
/// ```dart
/// final validator = v.num().min(5).max(20).positive();
///
/// print(validator.validate(10)); // true
/// print(validator.validate(3));  // false (less than min)
/// print(validator.validate(-5)); // false (not positive)
/// ```
class VNumber<T extends num> extends VRefine<T> {
  /// Sets a minimum value constraint.
  ///
  /// Ensures that the number is at least `min`.
  ///
  /// Example:
  /// ```dart
  /// final validator = v.num().min(10);
  /// print(validator.validate(9)); // false
  /// print(validator.validate(10)); // true
  /// ```
  VNumber min(T min, {String? message}) {
    add(MinValidator(min, message: message!));
    return this;
  }

  /// Sets a maximum value constraint.
  ///
  /// Ensures that the number does not exceed `max`.
  ///
  /// Example:
  /// ```dart
  /// final validator = v.num().max(100);
  /// print(validator.validate(101)); // false
  /// print(validator.validate(99)); // true
  /// ```
  VNumber max(T max, {String? message}) {
    add(MaxValidator(max, message: message!));
    return this;
  }

  /// Ensures the number is positive (`> 0`).
  ///
  /// Example:
  /// ```dart
  /// final validator = v.num().positive();
  /// print(validator.validate(-5)); // false
  /// print(validator.validate(3)); // true
  /// ```
  VNumber positive({String? message}) {
    add(PositiveValidator(message: message!));
    return this;
  }

  /// Ensures the number is negative (`< 0`).
  ///
  /// Example:
  /// ```dart
  /// final validator = v.num().negative();
  /// print(validator.validate(5)); // false
  /// print(validator.validate(-3)); // true
  /// ```
  VNumber negative({String? message}) {
    add(NegativeValidator(message: message!));
    return this;
  }

  /// Ensures the number falls within a range `[min, max]`.
  ///
  /// Example:
  /// ```dart
  /// final validator = v.num().between(10, 20);
  /// print(validator.validate(9)); // false
  /// print(validator.validate(15)); // true
  /// print(validator.validate(21)); // false
  /// ```
  VNumber between(T min, T max, {String? message}) {
    add(BetweenValidator(min, max, message: message!));
    return this;
  }

  /// Ensures the number is a multiple of the given factor.
  ///
  /// Example:
  /// ```dart
  /// final validator = v.num().multipleOf(5);
  /// print(validator.validate(10)); // true
  /// print(validator.validate(7));  // false
  /// ```
  VNumber multipleOf(T factor, {String? message}) {
    add(MultipleOfValidator(factor, message: message!));
    return this;
  }
}
