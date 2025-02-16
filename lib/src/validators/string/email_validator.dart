import 'package:validart/src/validators/string/pattern_validator.dart';

/// A validator that checks whether a given string is a valid email address.
///
/// The `EmailValidator` ensures that the input follows the basic structure
/// of an email address, including a local part, the `@` symbol, and a domain.
///
/// ## Email validation rules:
/// - The email must contain exactly one `@` symbol.
/// - The local part can include letters, numbers, and special characters.
/// - The domain must contain at least one dot (`.`).
/// - Consecutive dots (`..`) are not allowed.
///
/// ## Example usage:
/// ```dart
/// final validator = EmailValidator(message: 'Invalid email');
///
/// print(validator.validate('user@example.com'));  // null (valid)
/// print(validator.validate('user@sub.domain.com'));  // null (valid)
/// print(validator.validate('invalid-email'));  // 'Invalid email' (invalid)
/// print(validator.validate('user@domain'));  // 'Invalid email' (invalid)
/// print(validator.validate('user@domain..com'));  // 'Invalid email' (invalid)
/// ```
class EmailValidator extends PatternValidator {
  /// Creates an `EmailValidator` with a custom error [message].
  ///
  /// Uses a regex pattern to validate emails:
  /// - Prevents consecutive dots (`..`).
  /// - Ensures a valid domain format with at least two letters after the dot.
  EmailValidator({required super.message})
    : super(
        r"^(?!.*\.\.)[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+\.[a-zA-Z]{2,}$",
      );
}
