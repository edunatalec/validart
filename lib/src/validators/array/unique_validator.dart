import 'package:validart/src/validators/validator.dart';

/// A validator that checks if all elements in a list are unique.
///
/// The `UniqueValidator` ensures that a given list does not contain duplicate values.
///
/// ## Example usage:
/// ```dart
/// final validator = UniqueValidator(message: 'The list contains duplicate values');
///
/// print(validator.validate([1, 2, 3, 4])); // null (valid)
/// print(validator.validate(['a', 'b', 'c', 'a'])); // 'The list contains duplicate values' (invalid)
/// print(validator.validate([true, false, true])); // 'The list contains duplicate values' (invalid)
/// ```
///
/// ## Parameters:
/// - [message]: Custom error message when validation fails.
///
/// ## Behavior:
/// - If the list contains duplicate values, validation fails.
/// - If the list is empty or has only unique values, validation passes.
class UniqueValidator<T> extends Validator<List<T>> {
  /// Creates a `UniqueValidator` with a custom error message.
  UniqueValidator({required super.message});

  /// Validates whether all elements in the list are unique.
  ///
  /// - If the list is empty or contains only unique values, returns `null` (valid).
  /// - Otherwise, returns the error message.
  @override
  String? validate(covariant List<T> value) {
    final uniqueValues = value.toSet();

    if (uniqueValues.length == value.length) return null;

    return message;
  }
}
