import '../../v_code.dart';
import '../validator.dart';

/// Validates that a double has a fractional part (is not a whole number).
class DecimalValidator extends Validator<double> {
  /// Creates a [DecimalValidator].
  const DecimalValidator();

  @override
  String get code => VDoubleCode.decimal;

  @override
  Map<String, dynamic>? validate(double value) => value % 1 != 0 ? null : {};
}
