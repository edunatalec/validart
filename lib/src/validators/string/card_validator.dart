import 'package:validart/src/v_code.dart';
import 'package:validart/src/validation_mode.dart';
import 'package:validart/src/validators/string/card_brand_pattern.dart';
import 'package:validart/src/validators/validator.dart';

/// Validates that a string is a valid credit card number using the Luhn
/// algorithm. When [brands] is provided, the number must also match at
/// least one of the given [CardBrandPattern]s.
///
/// The [mode] field controls which input shape is accepted:
/// [ValidationMode.any] (default) strips spaces and dashes before the
/// Luhn check; [ValidationMode.formatted] requires digits grouped by
/// spaces or dashes in blocks of four; [ValidationMode.unformatted]
/// rejects any non-digit character.
class CardValidator extends Validator<String> {
  /// Optional list of accepted brands. When `null` or empty, any Luhn-valid
  /// card number is accepted.
  final List<CardBrandPattern>? brands;

  /// Controls whether separator characters are required, forbidden, or
  /// optional. Defaults to [ValidationMode.any].
  final ValidationMode mode;

  /// Creates a [CardValidator].
  const CardValidator({this.brands, this.mode = ValidationMode.any});

  @override
  String get code => VCode.card;

  @override
  Map<String, dynamic>? validate(String value) {
    if (!_matchesMode(value)) return {};

    final digits = value.replaceAll(RegExp(r'[\s-]'), '');

    if (digits.length < 13 || digits.length > 19) return {};

    if (digits.contains(RegExp(r'\D'))) return {};

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

  bool _matchesMode(String value) {
    switch (mode) {
      case ValidationMode.any:
        return true;
      case ValidationMode.unformatted:
        return RegExp(r'^\d+$').hasMatch(value);
      case ValidationMode.formatted:
        return RegExp(r'^\d{4}([ -]\d{4}){2,4}([ -]\d{1,3})?$').hasMatch(value);
    }
  }
}
