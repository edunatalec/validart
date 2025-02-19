import 'package:validart/src/validators/validator.dart';

/// A validator that ensures a given string is a valid Brazilian CNPJ.
///
/// The `CNPJValidator` checks whether the provided value follows the Brazilian
/// CNPJ format, which consists of exactly 14 digits (without special characters).
///
/// It also verifies:
/// - The CNPJ is not a repeated sequence (e.g., "00000000000000").
/// - The two check digits are correctly calculated.
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
class CNPJValidator extends ValidatorWithMessage<String> {
  /// Creates a `CNPJValidator` with a custom [message] for validation failures.
  CNPJValidator({required super.message});

  @override
  String? validate(covariant String value) {
    final cnpj = value.replaceAll(RegExp(r'[^\d]'), '');

    if (cnpj.length != 14 || RegExp(r'^(.)\1*$').hasMatch(cnpj)) {
      return message;
    }

    if (!_validateCNPJ(cnpj)) return message;

    return null;
  }

  /// Validates the check digits of a CNPJ.
  ///
  /// The CNPJ has two verification digits, calculated using specific weights.
  /// This function performs the required mathematical operations to verify their correctness.
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
