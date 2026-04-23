import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/string/postal_code_pattern.dart';
import 'package:validart/src/validators/validator.dart';

/// Validates that a string is a valid postal code for any of the given
/// patterns.
///
/// Validation succeeds when **any** pattern accepts the value, enabling
/// multi-country acceptance without a union:
///
/// ```dart
/// V.string().postalCode(patterns: [
///   const UsZipPattern(),
///   const CaPostalCodePattern(),
///   const UkPostcodePattern(),
/// ]);
/// ```
///
/// On failure the `{name}` interpolation param joins each pattern's
/// name with ` / ` (e.g. `US ZIP / Canadian Postal Code / UK Postcode`),
/// so a single template like `'Invalid {name}'` works regardless of how
/// many patterns are configured.
class PostalCodeValidator extends Validator<String> {
  /// The postal-code patterns accepted by this validator.
  final List<PostalCodePattern> patterns;

  /// Creates a [PostalCodeValidator]. The [patterns] list must be
  /// non-empty.
  PostalCodeValidator({required this.patterns})
    : assert(patterns.isNotEmpty, 'patterns must not be empty');

  @override
  String get code => VStringCode.postalCode;

  @override
  Map<String, dynamic>? validate(String value) {
    for (final pattern in patterns) {
      if (pattern.matches(value)) return null;
    }

    return {'name': patterns.map((p) => p.name).join(' / ')};
  }
}
