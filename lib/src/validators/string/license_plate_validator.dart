import '../../v_code.dart';
import '../validator.dart';
import 'license_plate_pattern.dart';

/// Validates that a string is a valid license plate for any of the
/// given patterns.
///
/// Validation succeeds when **any** pattern accepts the value, enabling
/// multi-country acceptance without a union:
///
/// ```dart
/// V.string().licensePlate(patterns: [
///   const UkPlatePattern(),
///   const BrMercosulPattern(), // from validart_br
/// ]);
/// ```
///
/// On failure the `{name}` interpolation param joins each pattern's
/// name with ` / ` (e.g. `UK Plate / Mercosul`), so a single template
/// like `'Invalid {name}'` works regardless of how many patterns are
/// configured.
class LicensePlateValidator extends Validator<String> {
  /// Creates a [LicensePlateValidator]. The [patterns] list must be
  /// non-empty.
  LicensePlateValidator({required this.patterns})
      : assert(patterns.isNotEmpty, 'patterns must not be empty');

  /// The license-plate patterns accepted by this validator.
  final List<LicensePlatePattern> patterns;

  @override
  String get code => VStringCode.licensePlate;

  @override
  Map<String, dynamic>? validate(String value) {
    for (final pattern in patterns) {
      if (pattern.matches(value)) return null;
    }

    return {'name': patterns.map((p) => p.name).join(' / ')};
  }
}
