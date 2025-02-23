import 'package:validart/src/enums/validation_mode.dart';
import 'package:validart/src/extensions/string_extensions.dart';
import 'package:validart/src/extensions/validation_mode_extensions.dart';
import 'package:validart/src/validators/validator.dart';

/// A validator that checks whether a given string is a valid Brazilian CPF number.
///
/// The `CPFValidator` ensures that the provided value follows the CPF format and
/// passes the official CPF checksum validation algorithm.
///
/// ## CPF Format:
/// - The CPF consists of **11 numeric digits**.
/// - It can be written in **formatted** (`XXX.XXX.XXX-XX`) or **unformatted** (`XXXXXXXXXXX`) forms.
///
/// ## Validation Modes:
/// - `ValidationMode.formatted` → Expects the CPF in the **formatted** pattern: `"XXX.XXX.XXX-XX"`
/// - `ValidationMode.unformatted` (default) → Expects only **digits**: `"XXXXXXXXXXX"`
///
/// ## Validation Rules:
/// - **Must contain exactly 11 digits**.
/// - **Cannot have all identical digits** (e.g., `"111.111.111-11"` is invalid).
/// - **Must pass the CPF checksum verification**, based on a mathematical algorithm.
///
/// ### Example
/// ```dart
/// final validator = CPFValidator(message: 'Invalid CPF');
///
/// print(validator.validate('123.456.789-09'));  // null (valid)
/// print(validator.validate('12345678909'));    // null (valid)
/// print(validator.validate('111.111.111-11')); // 'Invalid CPF' (invalid)
/// print(validator.validate('12345678900'));    // 'Invalid CPF' (invalid)
/// print(validator.validate('abcdefghijk'));    // 'Invalid CPF' (invalid)
/// ```
///
/// ## Behavior:
/// - Ensures the CPF format matches the expected pattern.
/// - Removes **non-digit characters** when `ValidationMode.unformatted` is used.
/// - Rejects **invalid CPF numbers** based on the official CPF validation algorithm.
class CPFValidator extends ValidatorWithMessage<String> {
  /// Defines whether the CPF should be validated as **formatted** (`XXX.XXX.XXX-XX`)
  /// or **unformatted** (`XXXXXXXXXXX`).
  final ValidationMode mode;

  /// Creates a `CPFValidator` instance with a custom error [message].
  ///
  /// By default, it expects an **unformatted** CPF (only digits).
  ///
  /// ```dart
  /// final validator = CPFValidator(message: 'Invalid CPF');
  ///
  /// print(validator.validate("123.456.789-09")); // null (valid)
  /// print(validator.validate("12345678909"));    // null (valid)
  ///
  /// final formattedValidator = CPFValidator(
  ///   message: 'Invalid CPF',
  ///   mode: ValidationMode.formatted,
  /// );
  ///
  /// print(formattedValidator.validate("123.456.789-09")); // null (valid)
  /// print(formattedValidator.validate("12345678909"));    // "Invalid CPF" (invalid)
  /// ```
  CPFValidator({
    required super.message,
    this.mode = ValidationMode.unformatted,
  });

  @override
  String? validate(covariant String value) {
    String cpf = mode.isUnformatted ? value.onlyDigits : value;

    final regex = mode.isFormatted
        ? RegExp(r'^\d{3}\.\d{3}\.\d{3}-\d{2}$')
        : RegExp(r'^\d{11}$');

    if (!regex.hasMatch(cpf)) return message;

    if (cpf.onlyDigits.isRepeatedCharacters) return message;

    if (!_validateCPF(cpf.onlyDigits)) return message;

    return null;
  }

  /// Performs the official CPF checksum validation.
  ///
  /// CPF numbers have **two check digits**, calculated using a weighted sum formula.
  /// This function performs the necessary operations to verify their correctness.
  ///
  /// ### Algorithm:
  /// 1. Multiply the first 9 digits by decreasing weights (from 10 to 2).
  /// 2. Compute the **first check digit** based on the weighted sum.
  /// 3. Multiply the first 10 digits (including the first check digit) by a new set of weights (from 11 to 2).
  /// 4. Compute the **second check digit**.
  /// 5. Compare the computed check digits with the ones in the input CPF.
  ///
  /// If both check digits match, the CPF is considered valid.
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
