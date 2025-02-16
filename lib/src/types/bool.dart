import 'package:keeper/src/messages/bool_message.dart';
import 'package:keeper/src/types/refine.dart';
import 'package:keeper/src/validators/bool/is_false_validator.dart';
import 'package:keeper/src/validators/bool/is_true_validator.dart';
import 'package:keeper/src/validators/required_validator.dart';
import 'package:keeper/src/validators/validator.dart';

/// A boolean validator for ensuring boolean values match specific conditions.
///
/// Example usage:
/// ```dart
/// final k = Keeper();
///
/// final validator = k.bool().isTrue();
/// print(validator.validate(true)); // true
/// print(validator.validate(false)); // false
/// ```
class KBool extends KRefine<bool> {
  /// Stores the validation messages for boolean-related errors.
  final BoolMessage _message;

  /// Creates an instance of `KBool` with optional custom validation messages.
  ///
  /// By default, it ensures the value is required unless explicitly marked as optional.
  KBool(this._message, {required String? message}) {
    add(RequiredValidator(message: message ?? _message.required));
  }

  /// Adds a validator to the `KBool` instance.
  ///
  /// Allows chaining multiple boolean validations.
  @override
  KBool add(KValidator<bool> validator) {
    super.add(validator);
    return this;
  }

  /// Validates that the value is `true`.
  ///
  /// Example:
  /// ```dart
  /// final k = Keeper();
  ///
  /// final validator = k.bool().isTrue();
  /// print(validator.validate(true)); // true
  /// print(validator.validate(false)); // false
  /// ```
  KBool isTrue({String? message}) {
    return add(IsTrueValidator(message: message ?? _message.isTrue));
  }

  /// Validates that the value is `false`.
  ///
  /// Example:
  /// ```dart
  /// final k = Keeper();
  ///
  /// final validator = k.bool().isFalse();
  /// print(validator.validate(false)); // true
  /// print(validator.validate(true)); // false
  /// ```
  KBool isFalse({String? message}) {
    return add(IsFalseValidator(message: message ?? _message.isFalse));
  }

  /// Validates that the value matches **any** of the provided `KBool` validators.
  ///
  /// Example:
  /// ```dart
  /// final k = Keeper();
  ///
  /// final validator = k.bool().any([
  ///   k.bool().isTrue(),
  ///   k.bool().isFalse()
  /// ]);
  ///
  /// print(validator.validate(true)); // true
  /// print(validator.validate(false)); // true
  /// ```
  @override
  KBool any(covariant List<KBool> types, {String? message}) {
    super.any(types, message: message ?? _message.any);
    return this;
  }

  /// Ensures that the value meets **all** the specified boolean validation rules.
  ///
  /// Example:
  /// ```dart
  /// final k = Keeper();
  ///
  /// final validator = k.bool().every([
  ///   k.bool().isTrue(),
  ///   k.bool().optional()
  /// ]);
  ///
  /// print(validator.validate(true)); // true
  /// print(validator.validate(null)); // true (optional allows null)
  /// print(validator.validate(false)); // false
  /// ```
  @override
  KBool every(covariant List<KBool> types, {String? message}) {
    super.every(types, message: message ?? _message.every);
    return this;
  }

  /// Makes the boolean field optional, allowing `null` values.
  ///
  /// Example:
  /// ```dart
  /// final k = Keeper();
  ///
  /// final validator = k.bool().optional();
  /// print(validator.validate(null)); // true
  /// print(validator.validate(true)); // true
  /// print(validator.validate(false)); // true
  /// ```
  @override
  KBool optional() {
    super.optional();
    return this;
  }

  /// Allows `null` values explicitly.
  ///
  /// Example:
  /// ```dart
  /// final k = Keeper();
  ///
  /// final validator = k.bool().nullable();
  /// print(validator.validate(null)); // true
  /// print(validator.validate(false)); // true
  /// ```
  @override
  KBool nullable() {
    super.nullable();
    return this;
  }

  /// Applies a custom validation function to the boolean value.
  ///
  /// Example:
  /// ```dart
  /// final k = Keeper();
  ///
  /// final validator = k.bool().refine((value) => value == true);
  ///
  /// print(validator.validate(true)); // true
  /// print(validator.validate(false)); // false
  /// ```
  @override
  KBool refine(bool Function(bool? data) validator, {String? message}) {
    super.refine(validator, message: message ?? _message.refine);
    return this;
  }
}
