import '../../validation_mode.dart';

/// A pluggable tax-identifier validation strategy.
///
/// The core ships with [UsSsnPattern], [UkNiNumberPattern] and
/// [CaSinPattern]. Country-specific tax IDs with check-digit algorithms
/// (e.g. BR CPF/CNPJ) can be added via extension packages like
/// `validart_br`.
///
/// ```dart
/// V.string().taxId(patterns: [const UsSsnPattern()]);
/// V.string().taxId(patterns: [const UkNiNumberPattern()]);
///
/// class CpfPattern extends TaxIdPattern {
///   const CpfPattern();
///   @override
///   String get name => 'CPF';
///   @override
///   bool matches(String value) { /* check digits */ }
/// }
/// ```
///
/// See also:
///
///  * [VString], which consumes patterns through its tax-id validator.
///  * [UsSsnPattern], [UkNiNumberPattern] and [CaSinPattern], the built-in
///    implementations.
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
///   patterns: [const UsSsnPattern(mode: ValidationMode.formatted)],
/// );
/// ```
///
/// See also:
///
///  * [TaxIdPattern], the contract this implements.
class UsSsnPattern extends TaxIdPattern {
  /// Creates a [UsSsnPattern].
  const UsSsnPattern({this.mode = ValidationMode.any});

  static final _formattedRegex = RegExp(r'^\d{3}-\d{2}-\d{4}$');
  static final _unformattedRegex = RegExp(r'^\d{9}$');

  /// Controls whether separators (dashes) are required, forbidden, or
  /// optional. Defaults to [ValidationMode.any].
  final ValidationMode mode;

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
///   patterns: [const UkNiNumberPattern(mode: ValidationMode.unformatted)],
/// );
/// ```
///
/// See also:
///
///  * [TaxIdPattern], the contract this implements.
class UkNiNumberPattern extends TaxIdPattern {
  /// Creates a [UkNiNumberPattern].
  const UkNiNumberPattern({this.mode = ValidationMode.any});

  static final _coreRegex =
      RegExp(r'^[A-CEGHJ-PR-TW-Z][A-CEGHJ-NPR-TW-Z]\d{6}[A-D]$');

  static final _formattedRegex = RegExp(
    r'^[A-CEGHJ-PR-TW-Z][A-CEGHJ-NPR-TW-Z] \d{2} \d{2} \d{2} [A-D]$',
  );

  /// Controls whether whitespace separators are required, forbidden, or
  /// optional. Defaults to [ValidationMode.any].
  final ValidationMode mode;

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
///   patterns: [const CaSinPattern(mode: ValidationMode.formatted)],
/// );
/// ```
///
/// See also:
///
///  * [TaxIdPattern], the contract this implements.
class CaSinPattern extends TaxIdPattern {
  /// Creates a [CaSinPattern].
  const CaSinPattern({this.mode = ValidationMode.any});

  static final _formattedRegex = RegExp(r'^\d{3}[ -]\d{3}[ -]\d{3}$');
  static final _unformattedRegex = RegExp(r'^\d{9}$');

  /// Controls whether separators (spaces or dashes) are required,
  /// forbidden, or optional. Defaults to [ValidationMode.any].
  final ValidationMode mode;

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

    return sum % 10 == 0;
  }
}
