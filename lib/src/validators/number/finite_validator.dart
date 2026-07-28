import '../../v_code.dart';
import '../validator.dart';

/// Validates that a double is finite (not infinite or NaN).
class FiniteValidator extends Validator<double> {
  /// Creates a [FiniteValidator].
  const FiniteValidator();

  @override
  String get code => VNumberCode.finite;

  @override
  Map<String, dynamic>? validate(double value) =>
      !value.isInfinite && !value.isNaN ? null : {};
}
