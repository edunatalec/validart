import 'package:keeper/src/validators/validator.dart';

/// A validator that checks whether a string matches a specific regular expression pattern.
///
/// The `PatternValidator` ensures that the input string adheres to a given regex pattern.
/// This allows for flexible validation of various formats, such as custom identifiers,
/// alphanumeric constraints, or other structured inputs.
///
/// ## Example usage:
/// ```dart
/// final validator = PatternValidator(
///   r'^[A-Za-z0-9]+$',
///   message: 'Only letters and numbers are allowed',
/// );
///
/// print(validator.validate('Valid123')); // null (valid)
/// print(validator.validate('Invalid@!')); // 'Only letters and numbers are allowed' (invalid)
/// ```
///
/// ## Parameters:
/// - [pattern]: The regular expression pattern used for validation.
/// - [message]: The error message returned if the validation fails.
///
/// ## Behavior:
/// - If the input value is `null`, validation fails.
/// - If the input does not match the specified regex pattern, validation fails.
/// - If the input matches the pattern, validation passes (`null` is returned).
class PatternValidator extends KValidator<String> {
  /// The regex pattern used for validation.
  final String pattern;

  /// Creates a `PatternValidator` with the given [pattern] and [message].
  PatternValidator(this.pattern, {required super.message});

  /// Validates whether the given [value] matches the expected pattern.
  ///
  /// - If the value is `null`, validation fails.
  /// - If the value matches the regex pattern, validation passes.
  /// - Otherwise, the provided error message is returned.
  ///
  /// Returns `null` if valid, otherwise returns the error message.
  @override
  String? validate(value) {
    if (value == null) return message;
    if (RegExp(pattern).hasMatch(value)) return null;

    return message;
  }
}
