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
class UsSsnPattern extends TaxIdPattern {
  /// Creates a [UsSsnPattern].
  const UsSsnPattern();

  @override
  String get name => 'US SSN';

  @override
  bool matches(String value) =>
      RegExp(r'^\d{3}-?\d{2}-?\d{4}$').hasMatch(value);
}

/// Matches UK National Insurance numbers (`AB123456C`).
///
/// Follows HMRC prefix rules: first char excludes `D/F/I/Q/U/V`, second
/// char excludes `D/F/I/O/Q/U/V`. The trailing letter is one of `A`–`D`.
class UkNiNumberPattern extends TaxIdPattern {
  /// Creates a [UkNiNumberPattern].
  const UkNiNumberPattern();

  @override
  String get name => 'UK National Insurance';

  @override
  bool matches(String value) {
    final normalized = value.replaceAll(' ', '').toUpperCase();

    return RegExp(
      r'^[A-CEGHJ-PR-TW-Z][A-CEGHJ-NPR-TW-Z]\d{6}[A-D]$',
    ).hasMatch(normalized);
  }
}

/// Matches Canadian Social Insurance Numbers — 9 digits with Luhn check.
///
/// Follows the CRA specification: the first digit must not be `0` or `8`.
/// Numbers beginning with `9` represent temporary residents; the others
/// cover provincial issuance ranges.
class CaSinPattern extends TaxIdPattern {
  /// Creates a [CaSinPattern].
  const CaSinPattern();

  @override
  String get name => 'Canadian SIN';

  @override
  bool matches(String value) {
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
