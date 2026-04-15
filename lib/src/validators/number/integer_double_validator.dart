import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

/// Validates that a double is a whole number (has no fractional part).
class IntegerDoubleValidator extends Validator<double> {
  /// Creates an [IntegerDoubleValidator].
  const IntegerDoubleValidator();

  @override
  String get code => VCode.integer;

  @override
  Map<String, dynamic>? validate(double value) => value % 1 == 0 ? null : {};
}
