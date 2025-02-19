import 'package:validart/src/messages/bool_message.dart';
import 'package:validart/src/types/array.dart';
import 'package:validart/src/types/primitive.dart';
import 'package:validart/src/validators/bool/is_false_validator.dart';
import 'package:validart/src/validators/bool/is_true_validator.dart';
import 'package:validart/src/validators/required_validator.dart';
import 'package:validart/src/validators/validator.dart';

/// A validator for `bool` values, providing validation rules for boolean-specific constraints.
///
/// This class enables defining validation rules for `true` or `false` values, ensuring that
/// the input meets specific conditions such as being required, optional, nullable, or matching
/// predefined constraints.
///
/// ## Example Usage:
/// ```dart
/// final v = Validart();
///
/// final validator = v.bool().isTrue();
///
/// print(validator.validate(true)); // true
/// print(validator.validate(false)); // false
/// ```
class VBool extends VPrimitive<bool> {
  /// Stores the validation messages for boolean-related errors.
  final BoolMessage _message;

  /// Creates an instance of `VBool` with optional custom validation messages.
  ///
  /// This constructor initializes the boolean validator and automatically applies
  /// a `RequiredValidator` to ensure that the value is not `null` unless marked as optional.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.bool();
  ///
  /// print(validator.validate(true)); // true (valid)
  /// print(validator.validate(false)); // true (valid)
  /// print(validator.validate(null)); // 'Value is required' (invalid)
  /// ```
  ///
  /// ### Parameters
  /// - [_message]: The validation messages used for error handling.
  /// - [message]: *(optional)* A custom error message for required validation.
  VBool(this._message, {required String? message}) {
    add(RequiredValidator(message: message ?? _message.required));
  }

  /// Ensures that the boolean value is `false`.
  ///
  /// This method adds an `IsFalseValidator` to check if the given boolean value is `false`.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.bool().isFalse();
  ///
  /// print(validator.validate(false)); // true
  /// print(validator.validate(true)); // false
  /// ```
  ///
  /// ### Parameters
  /// - [message] *(optional)* A custom validation message.
  ///
  /// ### Returns
  /// The current `VBool` instance with the `isFalse` validation applied.
  VBool isFalse({String? message}) {
    return add(IsFalseValidator(message: message ?? _message.isFalse));
  }

  /// Ensures that the boolean value is `true`.
  ///
  /// This method adds an `IsTrueValidator` to check if the given boolean value is `true`.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.bool().isTrue();
  ///
  /// print(validator.validate(true)); // true
  /// print(validator.validate(false)); // false
  /// ```
  ///
  /// ### Parameters
  /// - [message] *(optional)* A custom validation message.
  ///
  /// ### Returns
  /// The current `VBool` instance with the `isTrue` validation applied.
  VBool isTrue({String? message}) {
    return add(IsTrueValidator(message: message ?? _message.isTrue));
  }

  /// Adds a validator to the `VBool` instance.
  ///
  /// This method allows chaining multiple boolean validation rules to refine
  /// the validation logic.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.bool().add(MyCustomBoolValidator());
  /// ```
  ///
  /// ### Parameters
  /// - [validator]: A `Validator<bool>` instance to be added to the validation chain.
  ///
  /// ### Returns
  /// The current `VBool` instance with the added validator.
  @override
  VBool add(Validator<bool> validator) {
    super.add(validator);
    return this;
  }

  /// Creates an array validator (`VArray<bool>`) for validating lists of boolean values.
  ///
  /// This method enables validation of arrays containing boolean values, ensuring that
  /// each element adheres to the boolean validation rules applied to the `VBool` instance.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.bool().array();
  ///
  /// print(validator.validate([true, false, true])); // true
  /// print(validator.validate([true, true, false])); // true
  /// ```
  ///
  /// ### Parameters
  /// - [message] *(optional)* A custom error message to return if validation fails.
  ///
  /// ### Returns
  /// A `VArray<bool>` instance for validating lists of boolean values.
  @override
  VArray<bool> array({String? message}) {
    return VArray<bool>(this, _message.array, message: message);
  }

  /// Ensures that the boolean value satisfies **at least one** of the specified validation rules.
  ///
  /// This method applies multiple boolean validators and allows the value to pass **if at least one** of them is met.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.bool().any([
  ///   v.bool().isTrue(),
  ///   v.bool().nullable(),
  /// ]);
  ///
  /// print(validator.validate(true)); // true (meets `isTrue`)
  /// print(validator.validate(null)); // true (meets `nullable`)
  /// print(validator.validate(false)); // false (does not meet any condition)
  /// ```
  ///
  /// ### Parameters
  /// - [types]: A list of `VBool` validators, where at least one must be satisfied.
  /// - [message] *(optional)*: A custom validation message if the value does not satisfy any of the conditions.
  ///
  /// ### Returns
  /// The current `VBool` instance with the `any` validation applied.
  @override
  VBool any(covariant List<VBool> types, {String? message}) {
    super.any(types, message: message ?? _message.any);
    return this;
  }

  /// Ensures that the boolean value satisfies **all** the specified validation rules.
  ///
  /// This method applies multiple boolean validators and requires the value to pass **all** of them.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.bool().every([
  ///   v.bool().isTrue(),
  ///   v.bool().nullable(),
  /// ]);
  ///
  /// print(validator.validate(true)); // true
  /// print(validator.validate(null)); // true (nullable allows null)
  /// print(validator.validate(false)); // false (does not satisfy `isTrue`)
  /// ```
  ///
  /// ### Parameters
  /// - [types]: A list of `VBool` validators that the value must satisfy.
  /// - [message] *(optional)*: A custom validation message if the value does not meet all conditions.
  ///
  /// ### Returns
  /// The current `VBool` instance with the `every` validation applied.
  @override
  VBool every(covariant List<VBool> types, {String? message}) {
    super.every(types, message: message ?? _message.every);
    return this;
  }

  /// Marks the boolean value as optional.
  ///
  /// Unlike other data types, marking a `bool` as optional **does not** change its validation behavior,
  /// since `bool` values can only be `true` or `false`. This method exists for API consistency but does not
  /// alter the validation logic.
  ///
  /// If you need to allow `null` values, use `.nullable()` instead.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.bool().optional();
  ///
  /// print(validator.validate(true)); // true
  /// print(validator.validate(false)); // true
  /// print(validator.validate(null)); // false (use `.nullable()` to allow nulls)
  /// ```
  ///
  /// ### Returns
  /// The current `VBool` instance (without affecting validation).
  @override
  VBool optional() {
    super.optional();
    return this;
  }

  /// Marks the boolean value as nullable, allowing `null` as a valid input.
  ///
  /// Unlike `.optional()`, which does not change validation behavior for booleans, `.nullable()`
  /// explicitly allows `null` values to be considered valid.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.bool().nullable();
  ///
  /// print(validator.validate(true)); // true
  /// print(validator.validate(false)); // true
  /// print(validator.validate(null)); // true (null is allowed)
  /// ```
  ///
  /// ### Returns
  /// The current `VBool` instance with `nullable` validation applied.
  @override
  VBool nullable() {
    super.nullable();
    return this;
  }

  /// Applies a custom validation function to the boolean value.
  ///
  /// This method allows defining a custom validation rule that checks whether
  /// the boolean value satisfies a specific condition.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.bool().refine((value) => value == true);
  ///
  /// print(validator.validate(true)); // true
  /// print(validator.validate(false)); // false
  /// ```
  ///
  /// ### Parameters
  /// - [validator]: A function that takes a boolean value and returns `true` if valid.
  /// - [message] *(optional)* A custom error message to return if validation fails.
  ///
  /// ### Returns
  /// The current `VBool` instance with the custom validation applied.
  @override
  VBool refine(bool Function(bool data) validator, {String? message}) {
    super.refine(validator, message: message ?? _message.refine);
    return this;
  }
}
