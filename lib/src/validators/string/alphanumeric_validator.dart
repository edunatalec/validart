import 'package:validart/src/validators/string/pattern_validator.dart';

/// A validator that checks whether a given string is alphanumeric.
///
/// The `AlphanumericValidator` ensures that the input string contains only:
/// - **Letters (A-Z, a-z)**
/// - **Numbers (0-9)**
///
/// No spaces, symbols, or special characters are allowed.
///
/// ### Example
/// ```dart
/// final alphanumericValidator = AlphanumericValidator(message: 'Only letters and numbers are allowed');
///
/// print(alphanumericValidator.validate('Valid123')); // null (valid)
/// print(alphanumericValidator.validate('Invalid@!')); // 'Only letters and numbers are allowed' (invalid)
/// print(alphanumericValidator.validate('with space')); // 'Only letters and numbers are allowed' (invalid)
/// ```
///
/// ### Parameters
/// - [message]: Custom error message when validation fails.
class AlphanumericValidator extends PatternValidator {
  /// Creates an `AlphanumericValidator` to ensure only letters and numbers are allowed.
  AlphanumericValidator({required super.message}) : super(r'^[a-zA-Z0-9]+$');
}
