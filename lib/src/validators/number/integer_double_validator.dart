import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

class IntegerDoubleValidator extends Validator<double> {
  const IntegerDoubleValidator();

  @override
  String get code => VCode.integer;

  @override
  Map<String, dynamic>? validate(double value) => value % 1 == 0 ? null : {};
}
