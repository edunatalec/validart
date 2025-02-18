import 'package:validart/src/validators/validator.dart';

/// A validator that checks if a list contains all required elements.
///
/// The `ContainsArrayValidator` ensures that a given list includes a predefined set of elements.
///
/// ## Example usage:
/// ```dart
/// final validator = ContainsArrayValidator(
///   requiredElements: [1, 2, 3],
///   message: 'The list must contain all required elements',
/// );
///
/// print(validator.validate([1, 2, 3, 4, 5])); // null (valid)
/// print(validator.validate([1, 2])); // 'The list must contain all required elements' (invalid)
/// print(validator.validate(['a', 'b', 'c'])); // 'The list must contain all required elements' (invalid)
/// ```
///
/// ## Parameters:
/// - [requiredElements]: A list of elements that must be present.
/// - [message]: Custom error message when validation fails.
///
/// ## Behavior:
/// - If the list contains all required elements, validation passes.
/// - If any required element is missing, validation fails.
class ContainsArrayValidator<T> extends Validator<List<T>> {
  /// The required elements that must be present in the list.
  final List requiredElements;

  /// Creates a `ContainsArrayValidator` with a required elements list and a custom error message.
  ContainsArrayValidator({
    required this.requiredElements,
    required super.message,
  });

  /// Validates whether the list contains all required elements.
  ///
  /// - If all required elements are found, returns `null` (valid).
  /// - Otherwise, returns the error message.
  @override
  String? validate(covariant List<T> value) {
    final containsAll = requiredElements.every(value.contains);

    return containsAll ? null : message;
  }
}
