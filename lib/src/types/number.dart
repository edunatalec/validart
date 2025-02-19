import 'package:validart/src/types/primitive.dart';
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
abstract class VNumber<T extends num> extends VPrimitive<T> {
  /// Ensures that the numeric value is greater than or equal to the specified minimum.
  ///
  /// This method adds a `MinValidator` to check if the value meets the minimum threshold.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.num().min(10);
  ///
  /// print(validator.validate(15)); // true (valid)
  /// print(validator.validate(5));  // false (invalid)
  /// ```
  ///
  /// ### Parameters
  /// - [min]: The minimum allowed value.
  /// - [message] *(optional)*: A custom validation message that can be dynamically generated.
  ///
  /// ### Returns
  /// The current `VNumber<T>` instance with the `min` validation applied.
  VNumber<T> min(T min, {String Function(T min)? message}) {
    add(MinValidator(min, message: message!(min)));
    return this;
  }

  /// Ensures that the numeric value is less than or equal to the specified maximum.
  ///
  /// This method adds a `MaxValidator` to verify if the value does not exceed the maximum threshold.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.num().max(100);
  ///
  /// print(validator.validate(50));  // true (valid)
  /// print(validator.validate(150)); // false (invalid)
  /// ```
  ///
  /// ### Parameters
  /// - [max]: The maximum allowed value.
  /// - [message] *(optional)*: A custom validation message that can be dynamically generated.
  ///
  /// ### Returns
  /// The current `VNumber<T>` instance with the `max` validation applied.
  VNumber<T> max(T max, {String Function(T max)? message}) {
    add(MaxValidator(max, message: message!(max)));
    return this;
  }

  /// Ensures that the numeric value is positive (greater than `0`).
  ///
  /// This method adds a `PositiveValidator` to check whether the value is strictly greater than zero.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.num().positive();
  ///
  /// print(validator.validate(5));   // true (valid)
  /// print(validator.validate(0));   // false (invalid)
  /// print(validator.validate(-3));  // false (invalid)
  /// ```
  ///
  /// ### Parameters
  /// - [message] *(optional)*: A custom validation message.
  ///
  /// ### Returns
  /// The current `VNumber<T>` instance with the `positive` validation applied.
  VNumber<T> positive({String? message}) {
    add(PositiveValidator(message: message!));
    return this;
  }

  /// Ensures that the numeric value is negative (less than `0`).
  ///
  /// This method applies a `NegativeValidator` to check whether the value is strictly less than zero.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.num().negative();
  ///
  /// print(validator.validate(-5));  // true (valid)
  /// print(validator.validate(0));   // false (invalid)
  /// print(validator.validate(3));   // false (invalid)
  /// ```
  ///
  /// ### Parameters
  /// - [message] *(optional)*: A custom validation message.
  ///
  /// ### Returns
  /// The current `VNumber<T>` instance with the `negative` validation applied.
  VNumber<T> negative({String? message}) {
    add(NegativeValidator(message: message!));
    return this;
  }

  /// Ensures that the numeric value is within the specified range `[min, max]`.
  ///
  /// This method applies a `BetweenValidator` to check whether the value is greater than or equal to `min`
  /// and less than or equal to `max`.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.num().between(10, 50);
  ///
  /// print(validator.validate(25));  // true (valid)
  /// print(validator.validate(10));  // true (valid)
  /// print(validator.validate(50));  // true (valid)
  /// print(validator.validate(5));   // false (invalid)
  /// print(validator.validate(55));  // false (invalid)
  /// ```
  ///
  /// ### Parameters
  /// - [min]: The minimum allowed value.
  /// - [max]: The maximum allowed value.
  /// - [message] *(optional)*: A custom validation message.
  ///
  /// ### Returns
  /// The current `VNumber<T>` instance with the `between` validation applied.
  VNumber<T> between(T min, T max, {String Function(T min, T max)? message}) {
    add(BetweenValidator(min, max, message: message!(min, max)));
    return this;
  }

  /// Ensures that the numeric value is a multiple of the specified `factor`.
  ///
  /// This method applies a `MultipleOfValidator` to check whether the value is evenly divisible by `factor`.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.num().multipleOf(5);
  ///
  /// print(validator.validate(10));  // true (valid)
  /// print(validator.validate(15));  // true (valid)
  /// print(validator.validate(7));   // false (invalid)
  /// print(validator.validate(11));  // false (invalid)
  /// ```
  ///
  /// ### Parameters
  /// - [factor]: The number that the value must be a multiple of.
  /// - [message] *(optional)*: A custom validation message.
  ///
  /// ### Returns
  /// The current `VNumber<T>` instance with the `multipleOf` validation applied.
  VNumber<T> multipleOf(T factor, {String Function(T)? message}) {
    add(MultipleOfValidator(factor, message: message!(factor)));
    return this;
  }
}
