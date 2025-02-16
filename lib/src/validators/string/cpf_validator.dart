import 'package:validart/src/validators/validator.dart';

/// A validator that checks whether a given string is a valid Brazilian CPF number.
///
/// The `CPFValidator` ensures that the provided value follows the CPF format and
/// passes the official CPF checksum validation algorithm.
///
/// ## CPF Format:
/// - The CPF consists of 11 numeric digits.
/// - Common formats include `123.456.789-09` or `12345678909`.
///
/// ## Validation rules:
/// - Must be exactly 11 digits long.
/// - Cannot contain all identical digits (e.g., `111.111.111-11` is invalid).
/// - Must pass the CPF checksum verification.
///
/// ## Example usage:
/// ```dart
/// final validator = CPFValidator(message: 'Invalid CPF');
///
/// print(validator.validate('123.456.789-09'));  // null (valid)
/// print(validator.validate('111.111.111-11')); // 'Invalid CPF' (invalid)
/// print(validator.validate('12345678900'));    // 'Invalid CPF' (invalid)
/// ```
class CPFValidator extends Validator<String> {
  /// Creates a `CPFValidator` instance with a custom error [message].
  CPFValidator({required super.message});

  /// Validates whether the given [value] is a valid CPF number.
  ///
  /// - Removes non-numeric characters before validation.
  /// - Checks if the length is exactly 11 digits.
  /// - Rejects sequences of identical numbers (e.g., `111.111.111-11`).
  /// - Performs the official CPF checksum validation.
  ///
  /// Returns `null` if the CPF is valid, otherwise returns the error message.
  @override
  String? validate(String? value) {
    if (value == null) return message;

    // Remove non-numeric characters
    final cpf = value.replaceAll(RegExp(r'[^\d]'), '');

    // Check length and prevent repeated digits
    if (cpf.length != 11 || RegExp(r'^(.)\1*$').hasMatch(cpf)) {
      return message;
    }

    // Validate CPF checksum
    if (!_validateCPF(cpf)) return message;

    return null;
  }

  /// Performs the official CPF checksum validation.
  ///
  /// CPF uses two check digits to verify authenticity.
  /// This function computes and validates those digits.
  bool _validateCPF(String cpf) {
    int sum1 = 0, sum2 = 0;

    for (int i = 0; i < 9; i++) {
      sum1 += int.parse(cpf[i]) * (10 - i);
      sum2 += int.parse(cpf[i]) * (11 - i);
    }

    final int checkDigit1 = (sum1 * 10) % 11 % 10;
    sum2 += checkDigit1 * 2;
    final int checkDigit2 = (sum2 * 10) % 11 % 10;

    return cpf[9] == checkDigit1.toString() &&
        cpf[10] == checkDigit2.toString();
  }
}
