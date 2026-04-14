import 'package:validart/src/validators/validator.dart';

class DecimalValidator extends Validator<double> {
  const DecimalValidator({required super.message});

  @override
  String get code => 'decimal';

  @override
  String? validate(double value) => value % 1 != 0 ? null : message;
}
