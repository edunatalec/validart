import 'package:validart/src/validators/validator.dart';

class FiniteValidator extends Validator<double> {
  const FiniteValidator({required super.message});

  @override
  String get code => 'finite';

  @override
  String? validate(double value) =>
      !value.isInfinite && !value.isNaN ? null : message;
}
