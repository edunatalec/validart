import 'package:validart/src/validators/validator.dart';

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
class PatternValidator extends ValidatorWithMessage<String> {
  /// The regex pattern used for validation.
  final String pattern;

  /// Creates a `PatternValidator` with the given [pattern] and [message].
  PatternValidator(this.pattern, {required super.message});

  @override
  String? validate(covariant String value) {
    if (RegExp(pattern).hasMatch(value)) return null;

    return message;
  }
}
