import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/string/card_brand_pattern.dart';
import 'package:validart/src/validators/validator.dart';

/// Validates that a string is a valid credit card number using the Luhn
/// algorithm. When [brands] is provided, the number must also match at
/// least one of the given [CardBrandPattern]s.
class CardValidator extends Validator<String> {
  /// Optional list of accepted brands. When `null` or empty, any Luhn-valid
  /// card number is accepted.
  final List<CardBrandPattern>? brands;

  /// Creates a [CardValidator].
  const CardValidator({this.brands});

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

    if (sum % 10 != 0) return {};

    final accepted = brands;

    if (accepted != null && accepted.isNotEmpty) {
      final matched = accepted.any((brand) => brand.matches(digits));

      if (!matched) return {};
    }

    return null;
  }
}
