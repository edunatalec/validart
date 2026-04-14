import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

class DecimalValidator extends Validator<double> {
  const DecimalValidator();

  @override
  String get code => VCode.decimal;

  @override
  Map<String, dynamic>? validate(double value) => value % 1 != 0 ? null : {};
}
