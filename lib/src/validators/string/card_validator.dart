import 'package:validart/src/validators/validator.dart';

/// A validator that checks whether a given string is a valid credit or debit card number.
///
/// This validator ensures:
/// - The number consists of **only digits** (excluding spaces/hyphens).
/// - The length is between **13 and 19 digits**.
/// - The number passes the **Luhn Algorithm**, which is used to validate card numbers.
///
/// ### Example
/// ```dart
/// final cardValidator = CardValidator(message: 'Invalid card number');
///
/// print(cardValidator.validate('4111111111111111')); // null (valid)
/// print(cardValidator.validate('1234567812345678')); // 'Invalid card number' (invalid)
/// ```
///
/// ## Parameters:
/// - [message]: Custom error message when validation fails.
class CardValidator extends ValidatorWithMessage<String> {
  /// Creates a `CardValidator` instance with a custom error message.
  CardValidator({required super.message});

  @override
  String? validate(covariant String value) {
    // Remove spaces and hyphens
    final sanitized = value.replaceAll(RegExp(r'\D'), '');

    // Check length (common range: 13 to 19 digits)
    if (sanitized.length < 13 || sanitized.length > 19) return message;

    // Check if it's only digits
    if (!RegExp(r'^\d+$').hasMatch(sanitized)) return message;

    // Check Luhn Algorithm
    if (!_isValidLuhn(sanitized)) return message;

    return null;
  }

  /// Validates a card number using the **Luhn Algorithm**.
  ///
  /// The Luhn Algorithm works by:
  /// - Doubling every second digit from right to left.
  /// - If doubling results in a number greater than 9, subtract 9.
  /// - Summing all digits and checking if the total is a multiple of 10.
  bool _isValidLuhn(String number) {
    int sum = 0;
    bool alternate = false;

    for (int i = number.length - 1; i >= 0; i--) {
      int digit = int.parse(number[i]);

      if (alternate) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }

      sum += digit;
      alternate = !alternate;
    }

    return sum % 10 == 0;
  }
}
