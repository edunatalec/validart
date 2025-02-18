import 'package:validart/src/types/any_every.dart';
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
class VNumber<T extends num> extends VAnyEvery<T> {
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
  VNumber min(T min, {String Function(T min)? message}) {
    add(MinValidator(min, message: message!(min)));
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
  VNumber max(T max, {String Function(T max)? message}) {
    add(MaxValidator(max, message: message!(max)));
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
  VNumber between(T min, T max, {String Function(T min, T max)? message}) {
    add(BetweenValidator(min, max, message: message!(min, max)));
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
  VNumber multipleOf(T factor, {String Function(T)? message}) {
    add(MultipleOfValidator(factor, message: message!(factor)));
    return this;
  }
}
