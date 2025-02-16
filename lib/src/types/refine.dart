import 'package:keeper/src/types/type.dart';
import 'package:keeper/src/validators/refine_validator.dart';

/// A base class that extends `KType<T>` and provides custom validation rules.
///
/// Example usage:
/// ```dart
/// final validator = k.string().refine(
///   (value) => value != null && value.contains('@'),
///   message: 'Must contain "@"',
/// );
///
/// print(validator.validate('hello@example.com')); // true
/// print(validator.validate('helloexample.com')); // false
/// ```
class KRefine<T> extends KType<T> {
  /// Adds a custom refinement rule.
  ///
  /// The `validator` function takes the input value and returns `true` if valid
  /// or `false` otherwise. The `message` parameter specifies the error message
  /// when the validation fails.
  ///
  /// Example:
  /// ```dart
  /// final validator = k.int().refine(
  ///   (value) => value != null && value.isEven,
  ///   message: 'The number must be even',
  /// );
  ///
  /// print(validator.validate(4)); // true
  /// print(validator.validate(5)); // false
  /// ```
  KRefine<T> refine(bool Function(T? data) validator, {String? message}) {
    add(RefineValidator<T>(validator, message: message!));
    return this;
  }
}
