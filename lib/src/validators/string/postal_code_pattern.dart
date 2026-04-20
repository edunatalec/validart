/// A pluggable postal-code validation strategy.
///
/// Implement this class to plug country-specific postal-code validation
/// into [VString.postalCode]. The core ships with [UsZipPattern],
/// [CaPostalCodePattern] and [UkPostcodePattern]. External packages (e.g.
/// `validart_br` with CEP) can add more.
///
/// ```dart
/// class BrCepPattern extends PostalCodePattern {
///   const BrCepPattern();
///
///   @override
///   String get name => 'CEP';
///
///   @override
///   bool matches(String value) =>
///       RegExp(r'^\d{5}-?\d{3}$').hasMatch(value);
/// }
///
/// V.string().postalCode(pattern: const BrCepPattern());
/// ```
abstract class PostalCodePattern {
  /// Creates a [PostalCodePattern].
  const PostalCodePattern();

  /// Human-readable name used in error messages and debugging.
  String get name;

  /// Returns `true` if [value] matches this pattern's format.
  bool matches(String value);
}

/// Matches US ZIP codes (`12345` or `12345-6789`).
class UsZipPattern extends PostalCodePattern {
  /// Creates a [UsZipPattern].
  const UsZipPattern();

  @override
  String get name => 'US ZIP';

  @override
  bool matches(String value) => RegExp(r'^\d{5}(-\d{4})?$').hasMatch(value);
}

/// Matches Canadian postal codes (`A1A 1A1` — space optional).
class CaPostalCodePattern extends PostalCodePattern {
  /// Creates a [CaPostalCodePattern].
  const CaPostalCodePattern();

  @override
  String get name => 'Canadian Postal Code';

  @override
  bool matches(String value) => RegExp(
        r'^[ABCEGHJ-NPRSTVXY]\d[A-Z] ?\d[A-Z]\d$',
        caseSensitive: false,
      ).hasMatch(value);
}

/// Matches UK postcodes (common format; full RFC is more permissive).
class UkPostcodePattern extends PostalCodePattern {
  /// Creates a [UkPostcodePattern].
  const UkPostcodePattern();

  @override
  String get name => 'UK Postcode';

  @override
  bool matches(String value) => RegExp(
        r'^[A-Z]{1,2}\d[A-Z\d]? ?\d[A-Z]{2}$',
        caseSensitive: false,
      ).hasMatch(value);
}
