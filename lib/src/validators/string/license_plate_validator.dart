import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/string/license_plate_pattern.dart';
import 'package:validart/src/validators/validator.dart';

/// Validates that a string is a valid license plate for the given pattern.
class LicensePlateValidator extends Validator<String> {
  /// The license-plate pattern to match against.
  final LicensePlatePattern pattern;

  /// Creates a [LicensePlateValidator].
  const LicensePlateValidator({required this.pattern});

  @override
  String get code => VCode.licensePlate;

  @override
  Map<String, dynamic>? validate(String value) =>
      pattern.matches(value) ? null : {'name': pattern.name};
}
