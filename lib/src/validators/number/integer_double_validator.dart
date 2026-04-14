import 'package:validart/src/validators/validator.dart';

class IntegerDoubleValidator extends Validator<double> {
  const IntegerDoubleValidator({required super.message});

  @override
  String get code => 'integer';

  @override
  String? validate(double value) => value % 1 == 0 ? null : message;
}
