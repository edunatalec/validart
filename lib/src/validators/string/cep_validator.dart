import 'package:validart/src/validators/validator.dart';

/// A validator that ensures a given string is a valid Brazilian postal code (CEP).
///
/// The `CEPValidator` checks whether the provided value follows the Brazilian CEP format,
/// which consists of exactly 8 digits (without special characters) and is not a repeated sequence of numbers.
///
/// Example usage:
/// ```dart
/// final validator = CEPValidator(message: 'Invalid CEP');
///
/// print(validator.validate('01001-000'));  // null (valid)
/// print(validator.validate('01001000'));   // null (valid)
/// print(validator.validate('00000-000'));  // 'Invalid CEP' (invalid)
/// print(validator.validate('abcdefgh'));   // 'Invalid CEP' (invalid)
/// print(validator.validate('1234'));       // 'Invalid CEP' (invalid)
/// print(validator.validate(null));         // 'Invalid CEP' (invalid)
/// ```
class CEPValidator extends Validator<String> {
  /// Creates a `CEPValidator` with a custom [message] for validation failures.
  CEPValidator({required super.message});

  /// Validates whether the given [value] is a valid Brazilian CEP.
  ///
  /// - It removes all non-numeric characters.
  /// - It checks if the result is exactly 8 digits long.
  /// - It ensures the value is not a repeated sequence (e.g., "00000000", "11111111").
  ///
  /// Returns `null` if valid, otherwise returns the error message.
  @override
  String? validate(String? value) {
    if (value == null) return message;

    // Remove all non-numeric characters
    final cep = value.replaceAll(RegExp(r'[^\d]'), '');

    // Ensure it has exactly 8 digits
    if (!RegExp(r'^\d{8}$').hasMatch(cep)) return message;

    // Prevent repeated sequences (e.g., "00000000", "11111111")
    if (RegExp(r'^(.)\1*$').hasMatch(cep)) return message;

    return null;
  }
}
