import 'package:validart/src/messages/double_message.dart';
import 'package:validart/src/types/array.dart';
import 'package:validart/src/types/number.dart';
import 'package:validart/src/validators/double/decimal_validator.dart';
import 'package:validart/src/validators/double/finite_validator.dart';
import 'package:validart/src/validators/double/integer_validator.dart';
import 'package:validart/src/validators/required_validator.dart';
import 'package:validart/src/validators/validator.dart';

/// A validator for `double` values, supporting various constraints.
///
/// ### Example
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
  /// This constructor initializes the double validator and automatically applies
  /// a `RequiredValidator` to ensure that the value is present unless explicitly
  /// marked as nullable.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.double();
  ///
  /// print(validator.validate(3.14)); // true (valid)
  /// print(validator.validate(null)); // 'Value is required' (invalid)
  /// ```
  ///
  /// ### Parameters
  /// - [_message]: The validation messages used for error handling.
  /// - [message]: *(optional)* A custom error message for required validation.
  ///
  /// ### Behavior
  /// By default, this validator requires the double value to be present. To allow `null` values,
  /// use the `.nullable()` method.
  VDouble(this._message, {required String? message}) {
    add(RequiredValidator(message: message ?? _message.required));
  }

  /// Ensures that the value is a valid decimal number.
  ///
  /// This method adds a `DecimalValidator` to check if the provided double value
  /// is a valid decimal representation.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.double().decimal();
  ///
  /// print(validator.validate(3.14)); // true (valid)
  /// print(validator.validate(10.0)); // true (valid)
  /// print(validator.validate(5)); // false (invalid, not explicitly a decimal)
  /// ```
  ///
  /// ### Parameters
  /// - [message]: *(optional)* A custom validation message.
  ///
  /// ### Returns
  /// The current `VDouble` instance with the `decimal` validation applied.
  VDouble decimal({String? message}) {
    return add(DecimalValidator(message: message ?? _message.decimal));
  }

  /// Ensures that the value is a finite number.
  ///
  /// This method adds a `FiniteValidator` to check if the provided double value
  /// is a finite number (i.e., not `Infinity` or `NaN`).
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.double().finite();
  ///
  /// print(validator.validate(3.14)); // true (valid)
  /// print(validator.validate(double.infinity)); // false (invalid)
  /// print(validator.validate(double.nan)); // false (invalid)
  /// ```
  ///
  /// ### Parameters
  /// - [message]: *(optional)* A custom validation message.
  ///
  /// ### Returns
  /// The current `VDouble` instance with the `finite` validation applied.
  VDouble finite({String? message}) {
    return add(FiniteValidator(message: message ?? _message.finite));
  }

  /// Ensures that the value is an integer.
  ///
  /// This method adds an `IntegerValidator` to check if the provided double value
  /// is a whole number (i.e., it has no fractional part).
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.double().integer();
  ///
  /// print(validator.validate(10.0)); // true (valid)
  /// print(validator.validate(10.5)); // false (invalid)
  /// ```
  ///
  /// ### Parameters
  /// - [message]: *(optional)* A custom validation message.
  ///
  /// ### Returns
  /// The current `VDouble` instance with the `integer` validation applied.
  VDouble integer({String? message}) {
    return add(IntegerValidator(message: message ?? _message.integer));
  }

  /// Ensures that the double value is within the specified range `[min, max]`.
  ///
  /// This method applies a `BetweenValidator` to check whether the value is greater than or equal to `min`
  /// and less than or equal to `max`.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.double().between(10.0, 50.0);
  ///
  /// print(validator.validate(25.0));  // true (valid)
  /// print(validator.validate(10.0));  // true (valid)
  /// print(validator.validate(50.0));  // true (valid)
  /// print(validator.validate(5.0));   // false (invalid)
  /// print(validator.validate(55.0));  // false (invalid)
  /// ```
  ///
  /// ### Parameters
  /// - [min]: The minimum allowed value.
  /// - [max]: The maximum allowed value.
  /// - [message] *(optional)*: A custom validation message.
  ///
  /// ### Returns
  /// The current `VDouble` instance with the `between` validation applied.
  @override
  VDouble between(
    double min,
    double max, {
    String Function(double min, double max)? message,
  }) {
    super.between(min, max, message: message ?? _message.between);
    return this;
  }

  /// Ensures that the double value is less than or equal to the specified maximum.
  ///
  /// This method adds a `MaxValidator` to verify if the value does not exceed the maximum threshold.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.double().max(100.0);
  ///
  /// print(validator.validate(50.0));  // true (valid)
  /// print(validator.validate(150.9)); // false (invalid)
  /// ```
  ///
  /// ### Parameters
  /// - [max]: The maximum allowed value.
  /// - [message] *(optional)*: A custom validation message that can be dynamically generated.
  ///
  /// ### Returns
  /// The current `VDouble` instance with the `max` validation applied.
  @override
  VDouble max(double max, {String Function(double max)? message}) {
    super.max(max, message: message ?? _message.max);
    return this;
  }

  /// Ensures that the double value is greater than or equal to the specified minimum.
  ///
  /// This method adds a `MinValidator` to check if the value meets the minimum threshold.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.double().min(10.0);
  ///
  /// print(validator.validate(15.0)); // true (valid)
  /// print(validator.validate(5.0));  // false (invalid)
  /// ```
  ///
  /// ### Parameters
  /// - [min]: The minimum allowed value.
  /// - [message] *(optional)*: A custom validation message that can be dynamically generated.
  ///
  /// ### Returns
  /// The current `VDouble` instance with the `min` validation applied.
  @override
  VDouble min(double min, {String Function(double min)? message}) {
    super.min(min, message: message ?? _message.min);
    return this;
  }

  /// Ensures that the double value is a multiple of the specified `factor`.
  ///
  /// This method applies a `MultipleOfValidator` to check whether the value is evenly divisible by `factor`.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.double().multipleOf(5.0);
  ///
  /// print(validator.validate(10.0));  // true (valid)
  /// print(validator.validate(15.0));  // true (valid)
  /// print(validator.validate(7.0));   // false (invalid)
  /// print(validator.validate(11.0));  // false (invalid)
  /// ```
  ///
  /// ### Parameters
  /// - [factor]: The number that the value must be a multiple of.
  /// - [message] *(optional)*: A custom validation message.
  ///
  /// ### Returns
  /// The current `VDouble` instance with the `multipleOf` validation applied.
  @override
  VDouble multipleOf(double factor, {String Function(double factor)? message}) {
    super.multipleOf(factor, message: message ?? _message.multipleOf);
    return this;
  }

  /// Ensures that the double value is negative (less than `0`).
  ///
  /// This method applies a `NegativeValidator` to check whether the value is strictly less than zero.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.double().negative();
  ///
  /// print(validator.validate(-5.0));  // true (valid)
  /// print(validator.validate(0.0));   // false (invalid)
  /// print(validator.validate(3.0));   // false (invalid)
  /// ```
  ///
  /// ### Parameters
  /// - [message] *(optional)*: A custom validation message.
  ///
  /// ### Returns
  /// The current `VDouble` instance with the `negative` validation applied.
  @override
  VDouble negative({String? message}) {
    super.negative(message: message ?? _message.negative);
    return this;
  }

  /// Ensures that the double value is positive (greater than `0.0`).
  ///
  /// This method adds a `PositiveValidator` to check whether the value is strictly greater than zero.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.double().positive();
  ///
  /// print(validator.validate(5.0));   // true (valid)
  /// print(validator.validate(0.0));   // false (invalid)
  /// print(validator.validate(-3.0));  // false (invalid)
  /// ```
  ///
  /// ### Parameters
  /// - [message] *(optional)*: A custom validation message.
  ///
  /// ### Returns
  /// The current `VDouble` instance with the `positive` validation applied.
  @override
  VDouble positive({String? message}) {
    super.positive(message: message ?? _message.positive);
    return this;
  }

  /// Adds a validator to the `VDouble` instance.
  ///
  /// This method allows chaining multiple double validation rules.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.double().add(MyCustomDoubleValidator());
  /// ```
  ///
  /// ### Parameters
  /// - [validator]: The validator to be added.
  ///
  /// ### Returns
  /// The current `VDouble` instance with the added validator.
  @override
  VDouble add(Validator<double> validator) {
    super.add(validator);
    return this;
  }

  /// Ensures that the double value matches **any** of the provided `VDouble` validators.
  ///
  /// This method allows defining multiple conditions where at least **one** must be met
  /// for the validation to pass. If none of the conditions are satisfied, the validation fails.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.double().any([
  ///   v.double().min(10.0),
  ///   v.double().max(5.0)
  /// ]);
  ///
  /// print(validator.validate(12.0)); // true (passes min(10.0))
  /// print(validator.validate(3.0));  // true (passes max(5.0))
  /// print(validator.validate(7));  // false (fails both)
  /// ```
  ///
  /// ### Parameters
  /// - [types]: A list of `VDouble` validators that the value can match.
  /// - [message] *(optional)*: A custom error message if validation fails.
  ///
  /// ### Returns
  /// The current `VDouble` instance with the `any` validation applied.
  @override
  VDouble any(covariant List<VDouble> types, {String? message}) {
    super.any(types, message: message ?? _message.any);
    return this;
  }

  /// Creates an array validator (`VArray<double>`) for validating lists of double values.
  ///
  /// This allows validating an array where each element follows the rules defined in the `VDouble` instance.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.double().min(10.0).array();
  ///
  /// print(validator.validate([15.0, 20.0, 30.0])); // true (all values >= 10.0)
  /// print(validator.validate([5.0, 15.0, 20.0]));  // false (5.0 is less than 10.0)
  /// ```
  ///
  /// ### Parameters
  /// - [message] *(optional)*: A custom validation message for array validation errors.
  ///
  /// ### Returns
  /// A `VArray<double>` instance for validating lists of double values.
  @override
  VArray<double> array({String? message}) {
    return VArray<double>(this, _message.array, message: message);
  }

  /// Ensures that the double value meets **all** specified validation rules.
  ///
  /// This requires the number to pass all provided validators in the `types` list.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.double().every([
  ///   v.double().min(10),
  ///   v.double().max(100)
  /// ]);
  ///
  /// print(validator.validate(50));  // true (within range)
  /// print(validator.validate(5));   // false (less than 10)
  /// print(validator.validate(150)); // false (greater than 100)
  /// ```
  ///
  /// ### Parameters
  /// - [types]: A list of `VDouble` validators to be checked.
  /// - [message] *(optional)*: A custom validation message.
  ///
  /// ### Returns
  /// The current `VDouble` instance with the `every` validation applied.
  @override
  VDouble every(covariant List<VDouble> types, {String? message}) {
    super.every(types, message: message ?? _message.every);
    return this;
  }

  /// Marks the double value as nullable.
  ///
  /// This method allows `null` values to be considered valid, meaning the validator
  /// will not return an error if the input is `null`. This is useful when dealing
  /// with optional double fields that may not always have a value.
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
  /// The current `VDouble` instance with the `nullable` flag enabled.
  @override
  VDouble nullable() {
    super.nullable();
    return this;
  }

  /// Marks the double value as optional.
  ///
  /// Unlike other data types, marking a `double` as optional **does not** change its validation behavior,
  /// since double values always have a concrete representation (`0.0`, `1.5`, `-10.0`, etc.).
  /// This method exists for API consistency but does not alter the validation logic.
  ///
  /// If you need to allow `null` values, use `.nullable()` instead.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.double().optional();
  ///
  /// print(validator.validate(10)); // true
  /// print(validator.validate(0));  // true
  /// print(validator.validate(null)); // false (use `.nullable()` to allow nulls)
  /// ```
  ///
  /// ### Returns
  /// The current `VDouble` instance (without affecting validation).
  @override
  VDouble optional() {
    super.optional();
    return this;
  }

  /// Applies a custom validation function to the double value.
  ///
  /// This method allows defining a custom validation rule by providing a function
  /// that receives the double value and returns `true` if valid or `false` if invalid.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.double().refine((value) => value > 100.0);
  ///
  /// print(validator.validate(150.0)); // true
  /// print(validator.validate(50.0));  // false (fails custom validation)
  /// ```
  ///
  /// ### Parameters
  /// - [validator]: A function that takes a `double` value and returns `true` if valid.
  /// - [message] *(optional)*: A custom validation message if the function returns `false`.
  ///
  /// ### Returns
  /// The current `VDouble` instance with the custom validation applied.
  @override
  VDouble refine(bool Function(double data) validator, {String? message}) {
    super.refine(validator, message: message ?? _message.refine);
    return this;
  }
}
