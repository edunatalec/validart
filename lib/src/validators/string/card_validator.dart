import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

/// Validates that a string is a valid credit card number using the Luhn algorithm.
class CardValidator extends Validator<String> {
  /// Creates a [CardValidator].
  const CardValidator();

  @override
  String get code => VCode.card;

  @override
  Map<String, dynamic>? validate(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 13 || digits.length > 19) return {};

    int sum = 0;
    bool alternate = false;

    for (int i = digits.length - 1; i >= 0; i--) {
      int n = int.parse(digits[i]);
      if (alternate) {
        n *= 2;
        if (n > 9) n -= 9;
      }
      sum += n;
      alternate = !alternate;
    }

    return (sum % 10 == 0) ? null : {};
  }
}
