import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/string/tax_id_pattern.dart';
import 'package:validart/src/validators/validator.dart';

/// Validates that a string is a valid tax ID for the given pattern.
class TaxIdValidator extends Validator<String> {
  /// The tax-ID pattern to match against.
  final TaxIdPattern pattern;

  /// Creates a [TaxIdValidator].
  const TaxIdValidator({required this.pattern});

  @override
  String get code => VCode.taxId;

  @override
  Map<String, dynamic>? validate(String value) =>
      pattern.matches(value) ? null : {'name': pattern.name};
}
