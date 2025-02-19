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
/// ### Example
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
  /// This constructor initializes the integer validator and automatically applies
  /// a `RequiredValidator` to ensure that the value is provided unless marked as optional.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.int();
  ///
  /// print(validator.validate(10)); // true (valid)
  /// print(validator.validate(null)); // 'Value is required' (invalid)
  /// ```
  ///
  /// ### Parameters
  /// - [_message]: The validation messages used for error handling.
  /// - [message]: *(optional)* A custom error message for required validation.
  ///
  /// ### Behavior
  /// By default, this validator requires a non-null integer. To allow `null` values,
  /// use the `.nullable()` method.
  VInt(this._message, {required String? message}) {
    add(RequiredValidator(message: message ?? _message.required));
  }

  /// Ensures that the integer value is even.
  ///
  /// This method adds an `EvenValidator` to check whether the integer is an even number (`divisible by 2`).
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.int().even();
  ///
  /// print(validator.validate(4)); // true
  /// print(validator.validate(7)); // false
  /// ```
  ///
  /// ### Parameters
  /// - [message]: *(optional)* A custom error message.
  ///
  /// ### Returns
  /// The current `VInt` instance with the `even` validation applied.
  VInt even({String? message}) {
    return add(EvenValidator(message: message ?? _message.even));
  }

  /// Ensures that the integer value is odd.
  ///
  /// This method adds an `OddValidator` to check whether the integer is an odd number (`not divisible by 2`).
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.int().odd();
  ///
  /// print(validator.validate(3)); // true
  /// print(validator.validate(8)); // false
  /// ```
  ///
  /// ### Parameters
  /// - [message]: *(optional)* A custom error message.
  ///
  /// ### Returns
  /// The current `VInt` instance with the `odd` validation applied.
  VInt odd({String? message}) {
    return add(OddValidator(message: message ?? _message.odd));
  }

  /// Ensures that the integer value is a prime number.
  ///
  /// This method adds a `PrimeValidator` to check whether the integer is a prime number (`greater than 1` and only divisible by `1` and itself).
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.int().prime();
  ///
  /// print(validator.validate(7)); // true
  /// print(validator.validate(9)); // false
  /// ```
  ///
  /// ### Parameters
  /// - [message]: *(optional)* A custom error message.
  ///
  /// ### Returns
  /// The current `VInt` instance with the `prime` validation applied.
  VInt prime({String? message}) {
    return add(PrimeValidator(message: message ?? _message.prime));
  }

  /// Ensures that the int value is greater than or equal to the specified minimum.
  ///
  /// This method adds a `MinValidator` to check if the value meets the minimum threshold.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.int().min(10);
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
  /// The current `VInt` instance with the `min` validation applied.
  @override
  VInt between(int min, int max, {String Function(int min, int max)? message}) {
    super.between(min, max, message: message ?? _message.between);
    return this;
  }

  /// Ensures that the int value is less than or equal to the specified maximum.
  ///
  /// This method adds a `MaxValidator` to verify if the value does not exceed the maximum threshold.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.int().max(100);
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
  /// The current `VInt` instance with the `max` validation applied.
  @override
  VInt max(int max, {String Function(int)? message}) {
    super.max(max, message: message ?? _message.max);
    return this;
  }

  /// Ensures that the int value is positive (greater than `0`).
  ///
  /// This method adds a `PositiveValidator` to check whether the value is strictly greater than zero.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.int().positive();
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
  /// The current `VInt` instance with the `positive` validation applied.
  @override
  VInt min(int min, {String Function(int min)? message}) {
    super.min(min, message: message ?? _message.min);
    return this;
  }

  /// Ensures that the int value is negative (less than `0`).
  ///
  /// This method applies a `NegativeValidator` to check whether the value is strictly less than zero.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.int().negative();
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
  /// The current `VInt` instance with the `negative` validation applied.
  @override
  VInt multipleOf(int factor, {String Function(int)? message}) {
    super.multipleOf(factor, message: message ?? _message.multipleOf);
    return this;
  }

  /// Ensures that the int value is within the specified range `[min, max]`.
  ///
  /// This method applies a `BetweenValidator` to check whether the value is greater than or equal to `min`
  /// and less than or equal to `max`.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.int().between(10, 50);
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
  /// The current `VInt` instance with the `between` validation applied.
  @override
  VInt negative({String? message}) {
    super.negative(message: message ?? _message.negative);
    return this;
  }

  /// Ensures that the int value is a multiple of the specified `factor`.
  ///
  /// This method applies a `MultipleOfValidator` to check whether the value is evenly divisible by `factor`.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.int().multipleOf(5);
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
  /// The current `VInt` instance with the `multipleOf` validation applied.
  @override
  VInt positive({String? message}) {
    super.positive(message: message ?? _message.positive);
    return this;
  }

  /// Adds a validator to the `VInt` instance.
  ///
  /// This method allows chaining multiple int validation rules.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.int().add(MyCustomNumValidator());
  /// ```
  ///
  /// ### Parameters
  /// - [validator]: The validator to be added.
  ///
  /// ### Returns
  /// The current `VInt` instance with the added validator.
  @override
  VInt add(Validator<int> validator) {
    super.add(validator);
    return this;
  }

  /// Ensures that the int value matches **any** of the provided `VInt` validators.
  ///
  /// This method allows defining multiple conditions where at least **one** must be met
  /// for the validation to pass. If none of the conditions are satisfied, the validation fails.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.int().any([
  ///   v.int().min(10),
  ///   v.int().max(5)
  /// ]);
  ///
  /// print(validator.validate(12)); // true (passes min(10))
  /// print(validator.validate(3));  // true (passes max(5))
  /// print(validator.validate(7));  // false (fails both)
  /// ```
  ///
  /// ### Parameters
  /// - [types]: A list of `VInt` validators that the value can match.
  /// - [message] *(optional)*: A custom error message if validation fails.
  ///
  /// ### Returns
  /// The current `VInt` instance with the `any` validation applied.
  @override
  VInt any(covariant List<VInt> types, {String? message}) {
    super.any(types, message: message ?? _message.any);
    return this;
  }

  /// Creates an array validator (`VArray<int>`) for validating lists of int values.
  ///
  /// This allows validating an array where each element follows the rules defined in the `VInt` instance.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.int().min(10).array();
  ///
  /// print(validator.validate([15, 20, 30])); // true (all values >= 10)
  /// print(validator.validate([5, 15, 20]));  // false (5 is less than 10)
  /// ```
  ///
  /// ### Parameters
  /// - [message] *(optional)*: A custom validation message for array validation errors.
  ///
  /// ### Returns
  /// A `VArray<int>` instance for validating lists of int values.
  @override
  VArray<int> array({String? message}) {
    return VArray<int>(this, _message.array, message: message);
  }

  /// Ensures that the int value meets **all** specified validation rules.
  ///
  /// This requires the number to pass all provided validators in the `types` list.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.int().every([
  ///   v.int().min(10),
  ///   v.int().max(100)
  /// ]);
  ///
  /// print(validator.validate(50));  // true (within range)
  /// print(validator.validate(5));   // false (less than 10)
  /// print(validator.validate(150)); // false (greater than 100)
  /// ```
  ///
  /// ### Parameters
  /// - [types]: A list of `VInt` validators to be checked.
  /// - [message] *(optional)*: A custom validation message.
  ///
  /// ### Returns
  /// The current `VInt` instance with the `every` validation applied.
  @override
  VInt every(covariant List<VInt> types, {String? message}) {
    super.every(types, message: message ?? _message.every);
    return this;
  }

  /// Marks the int value as nullable.
  ///
  /// This method allows `null` values to be considered valid, meaning the validator
  /// will not return an error if the input is `null`. This is useful when dealing
  /// with optional intal fields that may not always have a value.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.int().nullable();
  ///
  /// print(validator.validate(10));  // true
  /// print(validator.validate(0));   // true
  /// print(validator.validate(null)); // true (null is now valid)
  /// ```
  ///
  /// ### Returns
  /// The current `VInt` instance with the `nullable` flag enabled.
  @override
  VInt nullable() {
    super.nullable();
    return this;
  }

  /// Marks the int value as optional.
  ///
  /// Unlike other data types, marking a `int` as optional **does not** change its validation behavior,
  /// since int values always have a concrete representation (`0`, `1.5`, `-10`, etc.).
  /// This method exists for API consistency but does not alter the validation logic.
  ///
  /// If you need to allow `null` values, use `.nullable()` instead.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.int().optional();
  ///
  /// print(validator.validate(10)); // true
  /// print(validator.validate(0));  // true
  /// print(validator.validate(null)); // false (use `.nullable()` to allow nulls)
  /// ```
  ///
  /// ### Returns
  /// The current `VInt` instance (without affecting validation).
  @override
  VInt optional() {
    super.optional();
    return this;
  }

  /// Applies a custom validation function to the int value.
  ///
  /// This method allows defining a custom validation rule by providing a function
  /// that receives the int value and returns `true` if valid or `false` if invalid.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.int().refine((value) => value > 100);
  ///
  /// print(validator.validate(150)); // true
  /// print(validator.validate(50));  // false (fails custom validation)
  /// ```
  ///
  /// ### Parameters
  /// - [validator]: A function that takes a `int` value and returns `true` if valid.
  /// - [message] *(optional)*: A custom validation message if the function returns `false`.
  ///
  /// ### Returns
  /// The current `VInt` instance with the custom validation applied.
  @override
  VInt refine(bool Function(int data) validator, {String? message}) {
    super.refine(validator, message: message ?? _message.refine);
    return this;
  }
}
