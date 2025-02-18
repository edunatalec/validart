import 'package:validart/src/validators/string/pattern_validator.dart';

/// A validator that checks whether a given string is a valid JWT (JSON Web Token).
///
/// A JWT consists of three Base64Url-encoded parts separated by dots (`.`):
/// - Header
/// - Payload
/// - Signature
///
/// ## Example usage:
/// ```dart
/// final jwtValidator = JwtValidator(message: 'Invalid JWT token');
///
/// print(jwtValidator.validate('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvbiBEb2UiLCJpYXQiOjE1MTYyMzkwMjJ9.sflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c')); // null (valid)
/// print(jwtValidator.validate('invalid-token')); // 'Invalid JWT token' (invalid)
/// ```
///
/// ## Parameters:
/// - [message]: Custom error message when validation fails.
///
/// ## JWT Format:
/// - Must contain **three** Base64Url-encoded parts separated by dots (`.`).
/// - The structure should follow: `<header>.<payload>.<signature>`.
class JwtValidator extends PatternValidator {
  /// Creates a `JwtValidator` to check if a string is a valid JWT.
  ///
  /// - Requires a [message] to specify the validation error.
  JwtValidator({required super.message})
      : super(r'^[A-Za-z0-9-_]+\.[A-Za-z0-9-_]+\.[A-Za-z0-9-_]+$');
}
