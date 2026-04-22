import 'package:validart/src/validation_mode.dart';

/// A pluggable tax-identifier validation strategy.
///
/// The core ships with [UsSsnPattern], [UkNiNumberPattern] and
/// [CaSinPattern]. Country-specific tax IDs with check-digit algorithms
/// (e.g. BR CPF/CNPJ) can be added via extension packages like
/// `validart_br`.
///
/// ```dart
/// V.string().taxId(pattern: const UsSsnPattern());
/// V.string().taxId(pattern: const UkNiNumberPattern());
///
/// class CpfPattern extends TaxIdPattern {
///   const CpfPattern();
///   @override
///   String get name => 'CPF';
///   @override
///   bool matches(String value) { /* check digits */ }
/// }
/// ```
abstract class TaxIdPattern {
  /// Creates a [TaxIdPattern].
  const TaxIdPattern();

  /// Human-readable name used in error messages and debugging.
  String get name;

  /// Returns `true` if [value] is a valid tax ID for this pattern.
  bool matches(String value);
}

/// Matches US Social Security Numbers (`123-45-6789` or `123456789`).
///
/// Format-only check — does not verify that the number has been issued.
/// The [mode] field controls which input shape is accepted: [ValidationMode.any]
/// (default) accepts either the fully-formatted or fully-unformatted
/// shape, [ValidationMode.formatted] requires the dashes, and
/// [ValidationMode.unformatted] rejects them.
///
/// ```dart
/// V.string().taxId(
///   pattern: const UsSsnPattern(mode: ValidationMode.formatted),
/// );
/// ```
class UsSsnPattern extends TaxIdPattern {
  static final _formattedRegex = RegExp(r'^\d{3}-\d{2}-\d{4}$');
  static final _unformattedRegex = RegExp(r'^\d{9}$');

  /// Controls whether separators (dashes) are required, forbidden, or
  /// optional. Defaults to [ValidationMode.any].
  final ValidationMode mode;

  /// Creates a [UsSsnPattern].
  const UsSsnPattern({this.mode = ValidationMode.any});

  @override
  String get name => 'US SSN';

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

/// Matches UK National Insurance numbers (`AB123456C`).
///
/// Follows HMRC prefix rules: first char excludes `D/F/I/Q/U/V`, second
/// char excludes `D/F/I/O/Q/U/V`. The trailing letter is one of `A`–`D`.
///
/// Canonical formatted shape uses single spaces between pairs:
/// `AB 12 34 56 C`. The [mode] field controls whether those spaces are
/// required, forbidden, or optional.
///
/// ```dart
/// V.string().taxId(
///   pattern: const UkNiNumberPattern(mode: ValidationMode.unformatted),
/// );
/// ```
class UkNiNumberPattern extends TaxIdPattern {
  static final _coreRegex =
      RegExp(r'^[A-CEGHJ-PR-TW-Z][A-CEGHJ-NPR-TW-Z]\d{6}[A-D]$');
  static final _formattedRegex = RegExp(
    r'^[A-CEGHJ-PR-TW-Z][A-CEGHJ-NPR-TW-Z] \d{2} \d{2} \d{2} [A-D]$',
  );

  /// Controls whether whitespace separators are required, forbidden, or
  /// optional. Defaults to [ValidationMode.any].
  final ValidationMode mode;

  /// Creates a [UkNiNumberPattern].
  const UkNiNumberPattern({this.mode = ValidationMode.any});

  @override
  String get name => 'UK National Insurance';

  @override
  bool matches(String value) {
    switch (mode) {
      case ValidationMode.formatted:
        return _formattedRegex.hasMatch(value.toUpperCase());
      case ValidationMode.unformatted:
        if (value.contains(' ')) return false;

        return _coreRegex.hasMatch(value.toUpperCase());
      case ValidationMode.any:
        final normalized = value.replaceAll(' ', '').toUpperCase();

        return _coreRegex.hasMatch(normalized);
    }
  }
}

/// Matches Canadian Social Insurance Numbers — 9 digits with Luhn check.
///
/// Follows the CRA specification: the first digit must not be `0` or `8`.
/// Numbers beginning with `9` represent temporary residents; the others
/// cover provincial issuance ranges.
///
/// Canonical formatted shape uses groups of three digits separated by
/// spaces or dashes: `123 456 789` / `123-456-789`. The [mode] field
/// controls whether those separators are required, forbidden, or
/// optional.
///
/// ```dart
/// V.string().taxId(
///   pattern: const CaSinPattern(mode: ValidationMode.formatted),
/// );
/// ```
class CaSinPattern extends TaxIdPattern {
  static final _formattedRegex = RegExp(r'^\d{3}[ -]\d{3}[ -]\d{3}$');
  static final _unformattedRegex = RegExp(r'^\d{9}$');

  /// Controls whether separators (spaces or dashes) are required,
  /// forbidden, or optional. Defaults to [ValidationMode.any].
  final ValidationMode mode;

  /// Creates a [CaSinPattern].
  const CaSinPattern({this.mode = ValidationMode.any});

  @override
  String get name => 'Canadian SIN';

  @override
  bool matches(String value) {
    final shapeOk = switch (mode) {
      ValidationMode.formatted => _formattedRegex.hasMatch(value),
      ValidationMode.unformatted => _unformattedRegex.hasMatch(value),
      ValidationMode.any =>
        _formattedRegex.hasMatch(value) || _unformattedRegex.hasMatch(value),
    };

    if (!shapeOk) return false;

    final digits = value.replaceAll(RegExp(r'[\s-]'), '');

    if (!RegExp(r'^[1-79]\d{8}$').hasMatch(digits)) return false;

    var sum = 0;
    var alternate = false;

    for (var i = digits.length - 1; i >= 0; i--) {
      var n = int.parse(digits[i]);

      if (alternate) {
        n *= 2;
        if (n > 9) n -= 9;
      }

      sum += n;
      alternate = !alternate;
    }

    return sum % 10 == 0;
  }
}
