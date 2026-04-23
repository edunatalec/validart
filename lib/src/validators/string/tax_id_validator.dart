import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/string/tax_id_pattern.dart';
import 'package:validart/src/validators/validator.dart';

/// Validates that a string is a valid tax ID for any of the given
/// patterns.
///
/// Validation succeeds when **any** pattern accepts the value, enabling
/// multi-country acceptance without a union:
///
/// ```dart
/// V.string().taxId(patterns: [
///   const UsSsnPattern(),
///   const UkNiNumberPattern(),
///   const CaSinPattern(),
/// ]);
/// ```
///
/// On failure the `{name}` interpolation param joins each pattern's
/// name with ` / ` (e.g. `SSN / UK NI Number / Canadian SIN`), so a
/// single template like `'Invalid {name}'` works regardless of how many
/// patterns are configured.
class TaxIdValidator extends Validator<String> {
  /// The tax-ID patterns accepted by this validator.
  final List<TaxIdPattern> patterns;

  /// Creates a [TaxIdValidator]. The [patterns] list must be non-empty.
  TaxIdValidator({required this.patterns})
    : assert(patterns.isNotEmpty, 'patterns must not be empty');

  @override
  String get code => VStringCode.taxId;

  @override
  Map<String, dynamic>? validate(String value) {
    for (final pattern in patterns) {
      if (pattern.matches(value)) return null;
    }

    return {'name': patterns.map((p) => p.name).join(' / ')};
  }
}
