/// A pluggable license-plate validation strategy.
///
/// The core ships with [UkPlatePattern] (post-2001 format, which is
/// stable nationwide). Plates from countries with heavy regional variation
/// — US (per-state) and Canada (per-province) — are intentionally not
/// built in; implement them per your use case or use extension packages.
///
/// ```dart
/// V.string().licensePlate(pattern: const UkPlatePattern());
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
/// two letters + two digits + three letters, space optional
/// (`AB12 CDE` or `AB12CDE`).
class UkPlatePattern extends LicensePlatePattern {
  /// Creates a [UkPlatePattern].
  const UkPlatePattern();

  @override
  String get name => 'UK Plate';

  @override
  bool matches(String value) => RegExp(
        r'^[A-Z]{2}\d{2} ?[A-Z]{3}$',
        caseSensitive: false,
      ).hasMatch(value);
}
