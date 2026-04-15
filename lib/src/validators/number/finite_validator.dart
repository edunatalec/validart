import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

/// Validates that a double is finite (not infinite or NaN).
class FiniteValidator extends Validator<double> {
  /// Creates a [FiniteValidator].
  const FiniteValidator();

  @override
  String get code => VCode.finite;

  @override
  Map<String, dynamic>? validate(double value) =>
      !value.isInfinite && !value.isNaN ? null : {};
}
