import 'package:validart/src/validation_mode.dart';

/// A pluggable license-plate validation strategy.
///
/// The core ships with [UkPlatePattern] (post-2001 format, which is
/// stable nationwide). Plates from countries with heavy regional variation
/// — US (per-state) and Canada (per-province) — are intentionally not
/// built in; implement them per your use case or use extension packages.
///
/// ```dart
/// V.string().licensePlate(patterns: [const UkPlatePattern()]);
///
/// class BrMercosulPattern extends LicensePlatePattern {
///   const BrMercosulPattern();
///   @override
///   String get name => 'BR Mercosul';
///   @override
///   bool matches(String value) =>
///       RegExp(r'^[A-Z]{3}\d[A-Z]\d{2}$').hasMatch(value);
/// }
/// ```
abstract class LicensePlatePattern {
  /// Creates a [LicensePlatePattern].
  const LicensePlatePattern();

  /// Human-readable name used in error messages and debugging.
  String get name;

  /// Returns `true` if [value] is a valid license plate for this pattern.
  bool matches(String value);
}

/// Matches UK license plates in the current format (post-2001):
/// two letters + two digits + three letters, with an optional space
/// between the two groups (`AB12 CDE` or `AB12CDE`).
///
/// The [mode] field controls whether the separating space is required,
/// forbidden, or optional.
///
/// ```dart
/// V.string().licensePlate(
///   patterns: [const UkPlatePattern(mode: ValidationMode.formatted)],
/// );
/// ```
class UkPlatePattern extends LicensePlatePattern {
  static final _formattedRegex = RegExp(
    r'^[A-Z]{2}\d{2} [A-Z]{3}$',
    caseSensitive: false,
  );
  static final _unformattedRegex = RegExp(
    r'^[A-Z]{2}\d{2}[A-Z]{3}$',
    caseSensitive: false,
  );

  /// Controls whether the separating space is required, forbidden, or
  /// optional. Defaults to [ValidationMode.any].
  final ValidationMode mode;

  /// Creates a [UkPlatePattern].
  const UkPlatePattern({this.mode = ValidationMode.any});

  @override
  String get name => 'UK Plate';

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
