/// A pluggable credit-card brand matching strategy.
///
/// Implement this class to plug country-specific card brands into
/// [VString.card]. The core ships with [VisaBrand], [MastercardBrand],
/// [AmexBrand], [DinersBrand], [DiscoverBrand] and [JcbBrand]. External
/// packages (for example `validart_br` with Elo and Hipercard) can add
/// more.
///
/// The [digits] argument passed to [matches] is already stripped of any
/// non-digit character (spaces, dashes), so implementations only need to
/// check numeric prefixes and length.
///
/// ```dart
/// class EloBrand extends CardBrandPattern {
///   const EloBrand();
///
///   @override
///   String get name => 'Elo';
///
///   @override
///   bool matches(String digits) { ... }
///
/// V.string().card(brands: [const EloBrand()]);
/// ```
///
/// See also:
///
///  * [VString], which consumes brands through its card validator.
///  * [VisaBrand], [MastercardBrand], [AmexBrand], [DinersBrand],
///    [DiscoverBrand] and [JcbBrand], the built-in implementations.
abstract class CardBrandPattern {
  /// Creates a [CardBrandPattern].
  const CardBrandPattern();

  /// Human-readable brand name (used for error messages and debugging).
  String get name;

  /// Returns `true` if [digits] matches this brand's prefix and length rules.
  ///
  /// [digits] contains only numeric characters — the caller strips spaces
  /// and dashes before invoking this method.
  bool matches(String digits);
}

/// Matches Visa cards.
///
/// Rules: starts with `4`, length 13, 16 or 19.
///
/// See also:
///
///  * [CardBrandPattern], the contract this implements.
class VisaBrand extends CardBrandPattern {
  /// Creates a [VisaBrand].
  const VisaBrand();

  @override
  String get name => 'Visa';

  @override
  bool matches(String digits) {
    final len = digits.length;

    if (len != 13 && len != 16 && len != 19) return false;

    return digits.startsWith('4');
  }
}

/// Matches Mastercard cards.
///
/// Rules: length 16 and prefix in `51-55` or `2221-2720`.
///
/// See also:
///
///  * [CardBrandPattern], the contract this implements.
class MastercardBrand extends CardBrandPattern {
  /// Creates a [MastercardBrand].
  const MastercardBrand();

  @override
  String get name => 'Mastercard';

  @override
  bool matches(String digits) {
    if (digits.length != 16) return false;

    final prefix2 = int.tryParse(digits.substring(0, 2));

    if (prefix2 != null && prefix2 >= 51 && prefix2 <= 55) return true;

    final prefix4 = int.tryParse(digits.substring(0, 4));

    return prefix4 != null && prefix4 >= 2221 && prefix4 <= 2720;
  }
}

/// Matches American Express cards.
///
/// Rules: starts with `34` or `37`, length 15.
///
/// See also:
///
///  * [CardBrandPattern], the contract this implements.
class AmexBrand extends CardBrandPattern {
  /// Creates an [AmexBrand].
  const AmexBrand();

  @override
  String get name => 'American Express';

  @override
  bool matches(String digits) {
    if (digits.length != 15) return false;

    return digits.startsWith('34') || digits.startsWith('37');
  }
}

/// Matches Diners Club cards.
///
/// Rules: length 14-19 and prefix in `300-305`, `3095`, `36`, `38` or `39`.
///
/// See also:
///
///  * [CardBrandPattern], the contract this implements.
class DinersBrand extends CardBrandPattern {
  /// Creates a [DinersBrand].
  const DinersBrand();

  @override
  String get name => 'Diners Club';

  @override
  bool matches(String digits) {
    final len = digits.length;

    if (len < 14 || len > 19) return false;

    if (digits.startsWith('36') ||
        digits.startsWith('38') ||
        digits.startsWith('39')) {
      return true;
    }

    if (digits.startsWith('3095')) return true;

    final prefix3 = int.tryParse(digits.substring(0, 3));

    return prefix3 != null && prefix3 >= 300 && prefix3 <= 305;
  }
}

/// Matches Discover cards.
///
/// Rules: length 16-19 and prefix in `6011`, `65`, `644-649` or
/// `622126-622925`.
///
/// See also:
///
///  * [CardBrandPattern], the contract this implements.
class DiscoverBrand extends CardBrandPattern {
  /// Creates a [DiscoverBrand].
  const DiscoverBrand();

  @override
  String get name => 'Discover';

  @override
  bool matches(String digits) {
    final len = digits.length;

    if (len < 16 || len > 19) return false;

    if (digits.startsWith('6011') || digits.startsWith('65')) return true;

    final prefix3 = int.tryParse(digits.substring(0, 3));

    if (prefix3 != null && prefix3 >= 644 && prefix3 <= 649) return true;

    final prefix6 = int.tryParse(digits.substring(0, 6));

    return prefix6 != null && prefix6 >= 622126 && prefix6 <= 622925;
  }
}

/// Matches JCB cards.
///
/// Rules: length 16-19 and prefix in `3528-3589`.
///
/// See also:
///
///  * [CardBrandPattern], the contract this implements.
class JcbBrand extends CardBrandPattern {
  /// Creates a [JcbBrand].
  const JcbBrand();

  @override
  String get name => 'JCB';

  @override
  bool matches(String digits) {
    final len = digits.length;

    if (len < 16 || len > 19) return false;

    final prefix4 = int.tryParse(digits.substring(0, 4));

    return prefix4 != null && prefix4 >= 3528 && prefix4 <= 3589;
  }
}
