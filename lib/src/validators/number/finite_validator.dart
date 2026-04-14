import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

class FiniteValidator extends Validator<double> {
  const FiniteValidator();

  @override
  String get code => VCode.finite;

  @override
  Map<String, dynamic>? validate(double value) =>
      !value.isInfinite && !value.isNaN ? null : {};
}
