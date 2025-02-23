import 'package:validart/src/enums/validation_mode.dart';
import 'package:validart/src/extensions/string_extensions.dart';
import 'package:validart/src/extensions/validation_mode_extensions.dart';
import 'package:validart/src/validators/validator.dart';

/// A validator that ensures a given string is a valid Brazilian CNPJ.
///
/// The `CNPJValidator` checks whether the provided value follows the Brazilian
/// CNPJ format, which consists of exactly **14 digits** (without special characters)
/// or **formatted as `XX.XXX.XXX/XXXX-XX`**.
///
/// It also verifies:
/// - The **CNPJ is not a repeated sequence** (e.g., `"00000000000000"`).
/// - The **two check digits** are correctly calculated.
///
/// ### Validation Modes
/// - `ValidationMode.formatted` → Expects the CNPJ in the **formatted** pattern: `"XX.XXX.XXX/XXXX-XX"`
/// - `ValidationMode.unformatted` (default) → Expects only **digits**: `"XXXXXXXXXXXXXX"`
///
/// ### Example
/// ```dart
/// final validator = CNPJValidator(message: 'Invalid CNPJ');
///
/// print(validator.validate('12.345.678/0001-95')); // null (valid)
/// print(validator.validate('12345678000195'));     // null (valid)
/// print(validator.validate('00.000.000/0000-00')); // 'Invalid CNPJ' (invalid)
/// print(validator.validate('invalid-cnpj'));       // 'Invalid CNPJ' (invalid)
/// print(validator.validate('11111111111111'));     // 'Invalid CNPJ' (invalid)
/// ```
///
/// ### Behavior
/// - Ensures the CNPJ format matches the expected pattern.
/// - Removes non-digit characters when `ValidationMode.unformatted` is used.
/// - Rejects values where all characters are the same (e.g., `"00000000000000"`).
/// - Validates **check digits** using the official CNPJ verification algorithm.
class CNPJValidator extends ValidatorWithMessage<String> {
  /// Defines whether the CNPJ should be validated as **formatted** (`XX.XXX.XXX/XXXX-XX`)
  /// or **unformatted** (`XXXXXXXXXXXXXX`).
  final ValidationMode mode;

  /// Creates a `CNPJValidator` with a custom [message] for validation failures.
  ///
  /// By default, it expects an **unformatted** CNPJ (14 digits).
  ///
  /// ```dart
  /// final validator = CNPJValidator(message: 'Invalid CNPJ');
  ///
  /// print(validator.validate("12.345.678/0001-95")); // null (valid)
  /// print(validator.validate("12345678000195"));     // null (valid)
  ///
  /// final formattedValidator = CNPJValidator(
  ///   message: 'Invalid CNPJ',
  ///   mode: ValidationMode.formatted,
  /// );
  ///
  /// print(formattedValidator.validate("12.345.678/0001-95")); // null (valid)
  /// print(formattedValidator.validate("12345678000195"));     // "Invalid CNPJ" (invalid)
  /// ```
  CNPJValidator({
    required super.message,
    this.mode = ValidationMode.unformatted,
  });

  @override
  String? validate(covariant String value) {
    String cnpj = mode.isUnformatted ? value.onlyDigits : value;

    final regex = mode.isFormatted
        ? RegExp(r'^\d{2}\.\d{3}\.\d{3}/\d{4}-\d{2}$')
        : RegExp(r'^\d{14}$');

    if (!regex.hasMatch(cnpj)) return message;

    if (cnpj.onlyDigits.isRepeatedCharacters) return message;

    if (!_validateCNPJ(cnpj.onlyDigits)) return message;

    return null;
  }

  /// Validates the check digits of a CNPJ.
  ///
  /// The CNPJ has two verification digits, calculated using specific weights.
  /// This function performs the required mathematical operations to verify their correctness.
  ///
  /// ### Algorithm:
  /// 1. Multiply the first 12 digits by a sequence of weights.
  /// 2. Compute the **first check digit** based on the weighted sum.
  /// 3. Multiply the first 13 digits (including the first check digit) by a different sequence of weights.
  /// 4. Compute the **second check digit** based on the new weighted sum.
  /// 5. Compare the computed check digits with the ones in the input.
  ///
  /// If both check digits match, the CNPJ is valid.
  bool _validateCNPJ(String cnpj) {
    final List<int> weights1 = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    final List<int> weights2 = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];

    int sum1 = 0, sum2 = 0;

    for (int i = 0; i < 12; i++) {
      sum1 += int.parse(cnpj[i]) * weights1[i];
    }
    final int checkDigit1 = (sum1 % 11 < 2) ? 0 : (11 - sum1 % 11);

    for (int i = 0; i < 13; i++) {
      sum2 += int.parse(cnpj[i]) * weights2[i];
    }
    final int checkDigit2 = (sum2 % 11 < 2) ? 0 : (11 - sum2 % 11);

    return cnpj[12] == checkDigit1.toString() &&
        cnpj[13] == checkDigit2.toString();
  }
}
