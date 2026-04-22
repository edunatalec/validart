import 'package:validart/src/validation_mode.dart';

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
///
/// The [mode] field controls whether the space between the forward
/// sortation area and local delivery unit is required, forbidden, or
/// optional.
///
/// ```dart
/// V.string().postalCode(
///   pattern: const CaPostalCodePattern(mode: ValidationMode.formatted),
/// );
/// ```
class CaPostalCodePattern extends PostalCodePattern {
  static final _formattedRegex = RegExp(
    r'^[ABCEGHJ-NPRSTVXY]\d[A-Z] \d[A-Z]\d$',
    caseSensitive: false,
  );
  static final _unformattedRegex = RegExp(
    r'^[ABCEGHJ-NPRSTVXY]\d[A-Z]\d[A-Z]\d$',
    caseSensitive: false,
  );

  /// Controls whether the separating space is required, forbidden, or
  /// optional. Defaults to [ValidationMode.any].
  final ValidationMode mode;

  /// Creates a [CaPostalCodePattern].
  const CaPostalCodePattern({this.mode = ValidationMode.any});

  @override
  bool matches(String value) {
    switch (mode) {
      case ValidationMode.formatted:
        return _formattedRegex.hasMatch(value);
      case ValidationMode.unformatted:
        return _unformattedRegex.hasMatch(value);
      case ValidationMode.any:
        return _formattedRegex.hasMatch(value) ||
            _unformattedRegex.hasMatch(value);
    }
  }

  @override
  String get name => 'Canadian Postal Code';
}

/// Matches UK postcodes (common format; full RFC is more permissive).
///
/// The [mode] field controls whether the space between the outward and
/// inward codes is required, forbidden, or optional.
///
/// ```dart
/// V.string().postalCode(
///   pattern: const UkPostcodePattern(mode: ValidationMode.formatted),
/// );
/// ```
class UkPostcodePattern extends PostalCodePattern {
  static final _formattedRegex = RegExp(
    r'^[A-Z]{1,2}\d[A-Z\d]? \d[A-Z]{2}$',
    caseSensitive: false,
  );
  static final _unformattedRegex = RegExp(
    r'^[A-Z]{1,2}\d[A-Z\d]?\d[A-Z]{2}$',
    caseSensitive: false,
  );

  /// Controls whether the separating space is required, forbidden, or
  /// optional. Defaults to [ValidationMode.any].
  final ValidationMode mode;

  /// Creates a [UkPostcodePattern].
  const UkPostcodePattern({this.mode = ValidationMode.any});

  @override
  String get name => 'UK Postcode';

  @override
  bool matches(String value) {
    switch (mode) {
      case ValidationMode.formatted:
        return _formattedRegex.hasMatch(value);
      case ValidationMode.unformatted:
        return _unformattedRegex.hasMatch(value);
      case ValidationMode.any:
        return _formattedRegex.hasMatch(value) ||
            _unformattedRegex.hasMatch(value);
    }
  }
}
