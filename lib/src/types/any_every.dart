import 'package:validart/src/types/refine.dart';
import 'package:validart/src/types/type.dart';
import 'package:validart/src/validators/any_validator.dart';
import 'package:validart/src/validators/every_validator.dart';

/// A validation class that supports `any` and `every` conditions.
///
/// Extends [VRefine] to allow chaining multiple validation rules where:
/// - `any`: The value must satisfy at least one of the given validation rules.
/// - `every`: The value must satisfy all of the given validation rules.
///
/// This class provides flexible validation options for complex scenarios.
class VAnyEvery<T> extends VRefine<T> {
  /// Validates if the value satisfies at least one of the provided types.
  ///
  /// This is useful when you want a value to match one of multiple possible formats.
  ///
  /// ### Example:
  /// ```dart
  /// final validator = v.string().any([
  ///   v.string().email(),
  ///   v.string().url(),
  /// ], message: 'Must be an email or URL');
  ///
  /// print(validator.validate('test@example.com')); // true
  /// print(validator.validate('https://example.com')); // true
  /// print(validator.validate('invalid-string')); // false
  /// ```
  VType<T> any(List<VType<T>> types, {String? message}) {
    return add(AnyValidator(types, message: message!));
  }

  /// Validates if the value satisfies all of the provided types.
  ///
  /// This is useful when you want to ensure that a value meets multiple conditions simultaneously.
  ///
  /// ### Example:
  /// ```dart
  /// final validator = v.string().every([
  ///   v.string().min(5),
  ///   v.string().contains('@'),
  /// ], message: 'Must be at least 5 characters and contain @');
  ///
  /// print(validator.validate('test@')); // true
  /// print(validator.validate('abcd@')); // true
  /// print(validator.validate('abcd')); // false
  /// ```
  VType<T> every(List<VType<T>> types, {String? message}) {
    return add(EveryValidator(types, message: message!));
  }
}
