import 'package:validart/src/messages/bool_message.dart';
import 'package:validart/src/types/any_every.dart';
import 'package:validart/src/validators/bool/is_false_validator.dart';
import 'package:validart/src/validators/bool/is_true_validator.dart';
import 'package:validart/src/validators/required_validator.dart';
import 'package:validart/src/validators/validator.dart';

/// A boolean validator for ensuring boolean values match specific conditions.
///
/// Example usage:
/// ```dart
/// final v = Validart();
///
/// final validator = v.bool().isTrue();
/// print(validator.validate(true)); // true
/// print(validator.validate(false)); // false
/// ```
class VBool extends VAnyEvery<bool> {
  /// Stores the validation messages for boolean-related errors.
  final BoolMessage _message;

  /// Creates an instance of `VBool` with optional custom validation messages.
  ///
  /// By default, it ensures the value is required unless explicitly marked as optional.
  VBool(this._message, {required String? message}) {
    add(RequiredValidator(message: message ?? _message.required));
  }

  /// Adds a validator to the `VBool` instance.
  ///
  /// Allows chaining multiple boolean validations.
  @override
  VBool add(Validator<bool> validator) {
    super.add(validator);
    return this;
  }

  /// Validates that the value is `true`.
  ///
  /// Example:
  /// ```dart
  /// final v = Validart();
  ///
  /// final validator = v.bool().isTrue();
  /// print(validator.validate(true)); // true
  /// print(validator.validate(false)); // false
  /// ```
  VBool isTrue({String? message}) {
    return add(IsTrueValidator(message: message ?? _message.isTrue));
  }

  /// Validates that the value is `false`.
  ///
  /// Example:
  /// ```dart
  /// final v = Validart();
  ///
  /// final validator = v.bool().isFalse();
  /// print(validator.validate(false)); // true
  /// print(validator.validate(true)); // false
  /// ```
  VBool isFalse({String? message}) {
    return add(IsFalseValidator(message: message ?? _message.isFalse));
  }

  /// Validates that the value matches **any** of the provided `VBool` validators.
  ///
  /// Example:
  /// ```dart
  /// final v = Validart();
  ///
  /// final validator = v.bool().any([
  ///   v.bool().isTrue(),
  ///   v.bool().isFalse()
  /// ]);
  ///
  /// print(validator.validate(true)); // true
  /// print(validator.validate(false)); // true
  /// ```
  @override
  VBool any(covariant List<VBool> types, {String? message}) {
    super.any(types, message: message ?? _message.any);
    return this;
  }

  /// Ensures that the value meets **all** the specified boolean validation rules.
  ///
  /// Example:
  /// ```dart
  /// final v = Validart();
  ///
  /// final validator = v.bool().every([
  ///   v.bool().isTrue(),
  ///   v.bool().optional()
  /// ]);
  ///
  /// print(validator.validate(true)); // true
  /// print(validator.validate(null)); // true (optional allows null)
  /// print(validator.validate(false)); // false
  /// ```
  @override
  VBool every(covariant List<VBool> types, {String? message}) {
    super.every(types, message: message ?? _message.every);
    return this;
  }

  /// Makes the boolean field optional, allowing `null` values.
  ///
  /// Example:
  /// ```dart
  /// final v = Validart();
  ///
  /// final validator = v.bool().optional();
  /// print(validator.validate(null)); // true
  /// print(validator.validate(true)); // true
  /// print(validator.validate(false)); // true
  /// ```
  @override
  VBool optional() {
    super.optional();
    return this;
  }

  /// Allows `null` values explicitly.
  ///
  /// Example:
  /// ```dart
  /// final v = Validart();
  ///
  /// final validator = v.bool().nullable();
  /// print(validator.validate(null)); // true
  /// print(validator.validate(false)); // true
  /// ```
  @override
  VBool nullable() {
    super.nullable();
    return this;
  }

  /// Applies a custom validation function to the boolean value.
  ///
  /// Example:
  /// ```dart
  /// final v = Validart();
  ///
  /// final validator = v.bool().refine((value) => value == true);
  ///
  /// print(validator.validate(true)); // true
  /// print(validator.validate(false)); // false
  /// ```
  @override
  VBool refine(bool Function(bool data) validator, {String? message}) {
    super.refine(validator, message: message ?? _message.refine);
    return this;
  }
}
