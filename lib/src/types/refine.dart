import 'package:validart/src/types/type.dart';
import 'package:validart/src/validators/refine_validator.dart';

/// A base class that extends `VType<T>` and provides custom validation rules.
///
/// Example usage:
/// ```dart
/// final validator = v.string().refine(
///   (value) => value.contains('@'),
///   message: 'Must contain "@"',
/// );
///
/// print(validator.validate('hello@example.com')); // true
/// print(validator.validate('helloexample.com')); // false
/// ```
abstract class VRefine<T> extends VType<T> {
  /// Applies a custom validation rule using a refine function.
  ///
  /// This method allows defining a custom validation logic by providing a
  /// function that checks whether a given value meets the specified criteria.
  /// If the value does not satisfy the condition, the validation fails and returns
  /// the specified error message.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.string().refine(
  ///   (value) => value.contains('@'),
  ///   message: 'Must contain @ symbol',
  /// );
  ///
  /// print(validator.validate('example@email.com')); // null (valid)
  /// print(validator.validate('example.com')); // 'Must contain @ symbol' (invalid)
  /// ```
  ///
  /// ### Parameters
  /// - [validator]: A function that takes a value of type `T` and returns `true`
  ///   if it passes validation or `false` otherwise.
  /// - [message]: The error message returned if validation fails.
  ///
  /// ### Returns
  /// The current `VRefine<T>` instance with the refine validation applied.
  VRefine<T> refine(bool Function(T data) validator, {String? message}) {
    add(RefineValidator<T>(validator, message: message!));
    return this;
  }
}
