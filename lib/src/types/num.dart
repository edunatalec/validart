import 'package:validart/src/messages/num_message.dart';
import 'package:validart/src/types/array.dart';
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

  /// Creates an instance of `VNum` with optional custom validation messages.
  ///
  /// This constructor initializes the number validator and automatically applies
  /// a `RequiredValidator` to ensure that the value is not `null` unless marked as nullable.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.num();
  ///
  /// print(validator.validate(10));  // true (valid)
  /// print(validator.validate(null)); // 'Value is required' (invalid)
  /// ```
  ///
  /// ### Parameters
  /// - [_message]: The validation messages used for error handling.
  /// - [message] *(optional)*: A custom validation message for required values.
  ///
  /// ### Behavior
  /// By default, this validator requires the value to be defined. To allow `null` values,
  /// use the `.nullable()` method.
  VNum(this._message, {required String? message}) {
    add(RequiredValidator(message: message ?? _message.required));
  }

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
  /// The current `VNum` instance with the `min` validation applied.
  @override
  VNum min(num min, {String Function(num)? message}) {
    super.min(min, message: message ?? _message.min);
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
  /// The current `VNum` instance with the `max` validation applied.
  @override
  VNum max(num max, {String Function(num)? message}) {
    super.max(max, message: message ?? _message.max);
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
  /// The current `VNum` instance with the `positive` validation applied.
  @override
  VNum positive({String? message}) {
    super.positive(message: message ?? _message.positive);
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
  /// The current `VNum` instance with the `negative` validation applied.
  @override
  VNum negative({String? message}) {
    super.negative(message: message ?? _message.negative);
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
  /// The current `VNum` instance with the `between` validation applied.
  @override
  VNum between(num min, num max, {String Function(num min, num max)? message}) {
    super.between(min, max, message: message ?? _message.between);
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
  /// The current `VNum` instance with the `multipleOf` validation applied.
  @override
  VNum multipleOf(num factor, {String Function(num)? message}) {
    super.multipleOf(factor, message: message ?? _message.multipleOf);
    return this;
  }

  /// Adds a validator to the `VNum` instance.
  ///
  /// This method allows chaining multiple numeric validation rules.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.num().add(MyCustomValidator());
  /// ```
  ///
  /// ### Parameters
  /// - [validator]: The validator to be added.
  ///
  /// ### Returns
  /// The current `VNum` instance with the added validator.
  @override
  VNum add(Validator<num> validator) {
    super.add(validator);
    return this;
  }

  /// Ensures that the numeric value matches **any** of the provided `VNum` validators.
  ///
  /// This method allows defining multiple conditions where at least **one** must be met
  /// for the validation to pass. If none of the conditions are satisfied, the validation fails.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.num().any([
  ///   v.num().min(10),
  ///   v.num().max(5)
  /// ]);
  ///
  /// print(validator.validate(12)); // true (passes min(10))
  /// print(validator.validate(3));  // true (passes max(5))
  /// print(validator.validate(7));  // false (fails both)
  /// ```
  ///
  /// ### Parameters
  /// - [types]: A list of `VNum` validators that the value can match.
  /// - [message] *(optional)*: A custom error message if validation fails.
  ///
  /// ### Returns
  /// The current `VNum` instance with the `any` validation applied.
  @override
  VNum any(covariant List<VNum> types, {String? message}) {
    super.any(types, message: message ?? _message.any);
    return this;
  }

  /// Creates an array validator (`VArray<num>`) for validating lists of numeric values.
  ///
  /// This allows validating an array where each element follows the rules defined in the `VNum` instance.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.num().min(10).array();
  ///
  /// print(validator.validate([15, 20, 30])); // true (all values >= 10)
  /// print(validator.validate([5, 15, 20]));  // false (5 is less than 10)
  /// ```
  ///
  /// ### Parameters
  /// - [message] *(optional)*: A custom validation message for array validation errors.
  ///
  /// ### Returns
  /// A `VArray<num>` instance for validating lists of numeric values.
  @override
  VArray<num> array({String? message}) {
    return VArray<num>(this, _message.array, message: message);
  }

  /// Ensures that the numeric value meets **all** specified validation rules.
  ///
  /// This requires the number to pass all provided validators in the `types` list.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.num().every([
  ///   v.num().min(10),
  ///   v.num().max(100)
  /// ]);
  ///
  /// print(validator.validate(50));  // true (within range)
  /// print(validator.validate(5));   // false (less than 10)
  /// print(validator.validate(150)); // false (greater than 100)
  /// ```
  ///
  /// ### Parameters
  /// - [types]: A list of `VNum` validators to be checked.
  /// - [message] *(optional)*: A custom validation message.
  ///
  /// ### Returns
  /// The current `VNum` instance with the `every` validation applied.
  @override
  VNum every(covariant List<VNum> types, {String? message}) {
    super.every(types, message: message ?? _message.every);
    return this;
  }

  /// Marks the numeric value as optional.
  ///
  /// Unlike other data types, marking a `num` as optional **does not** change its validation behavior,
  /// since numeric values always have a concrete representation (`0`, `1.5`, `-10`, etc.).
  /// This method exists for API consistency but does not alter the validation logic.
  ///
  /// If you need to allow `null` values, use `.nullable()` instead.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.num().optional();
  ///
  /// print(validator.validate(10)); // true
  /// print(validator.validate(0));  // true
  /// print(validator.validate(null)); // false (use `.nullable()` to allow nulls)
  /// ```
  ///
  /// ### Returns
  /// The current `VNum` instance (without affecting validation).
  @override
  VNum optional() {
    super.optional();
    return this;
  }

  /// Marks the numeric value as nullable.
  ///
  /// This method allows `null` values to be considered valid, meaning the validator
  /// will not return an error if the input is `null`. This is useful when dealing
  /// with optional numerical fields that may not always have a value.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.num().nullable();
  ///
  /// print(validator.validate(10));  // true
  /// print(validator.validate(0));   // true
  /// print(validator.validate(null)); // true (null is now valid)
  /// ```
  ///
  /// ### Returns
  /// The current `VNum` instance with the `nullable` flag enabled.
  @override
  VNum nullable() {
    super.nullable();
    return this;
  }

  /// Applies a custom validation function to the numeric value.
  ///
  /// This method allows defining a custom validation rule by providing a function
  /// that receives the numeric value and returns `true` if valid or `false` if invalid.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.num().refine((value) => value > 100);
  ///
  /// print(validator.validate(150)); // true
  /// print(validator.validate(50));  // false (fails custom validation)
  /// ```
  ///
  /// ### Parameters
  /// - [validator]: A function that takes a `num` value and returns `true` if valid.
  /// - [message] *(optional)*: A custom validation message if the function returns `false`.
  ///
  /// ### Returns
  /// The current `VNum` instance with the custom validation applied.
  @override
  VNum refine(bool Function(num data) validator, {String? message}) {
    super.refine(validator, message: message ?? _message.refine);
    return this;
  }
}
