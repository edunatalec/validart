import 'package:validart/src/validators/string/pattern_validator.dart';

/// A validator that checks whether a given string contains only letters.
///
/// The `AlphaValidator` ensures that the input string contains only:
/// - **Uppercase letters (A-Z)**
/// - **Lowercase letters (a-z)**
///
/// No numbers, spaces, or special characters are allowed.
///
/// ## Example usage:
/// ```dart
/// final alphaValidator = AlphaValidator(message: 'Only letters are allowed');
///
/// print(alphaValidator.validate('ValidText')); // null (valid)
/// print(alphaValidator.validate('123ABC')); // 'Only letters are allowed' (invalid)
/// print(alphaValidator.validate('Hello World')); // 'Only letters are allowed' (invalid)
/// print(alphaValidator.validate('Test@')); // 'Only letters are allowed' (invalid)
/// ```
///
/// ## Parameters:
/// - [message]: Custom error message when validation fails.
class AlphaValidator extends PatternValidator {
  /// Creates an `AlphaValidator` to ensure only letters are allowed.
  AlphaValidator({required super.message}) : super(r'^[a-zA-Z]+$');
}
