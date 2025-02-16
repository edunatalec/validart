import 'package:keeper/src/types/type.dart';

/// A generic validator for arrays, ensuring that each item in the list
/// meets the validation criteria defined by a given `KType<T>`.
///
/// This class is useful for validating lists of values, where each element
/// must conform to the specified validation rules.
///
/// Example usage:
/// ```dart
/// final arrayValidator = KArray(k.string().email());
///
/// final isValid = arrayValidator.validate(['test@email.com', 'hello@world.com']);
/// print(isValid); // true
///
/// final isInvalid = arrayValidator.validate(['invalid-email', 'test@email.com']);
/// print(isInvalid); // false
/// ```
class KArray<T> {
  /// The validation type that will be applied to each element in the array.
  final KType<T> _type;

  /// Creates an instance of `KArray`, applying the given type validator to each element in the array.
  KArray(this._type);

  /// Validates a list of values, ensuring that each item in the array
  /// passes the validation defined by `_type`.
  ///
  /// Returns `true` if all elements are valid, otherwise returns `false`.
  ///
  /// Example:
  /// ```dart
  /// final arrayValidator = KArray(k.int().positive());
  ///
  /// print(arrayValidator.validate([1, 2, 3])); // true
  /// print(arrayValidator.validate([1, -2, 3])); // false
  /// ```
  bool validate(List<T> values) {
    for (final value in values) {
      final isValid = _type.validate(value);

      if (isValid) continue;
      return false;
    }
    return true;
  }
}
