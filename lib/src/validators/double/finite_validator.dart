import 'package:keeper/src/validators/validator.dart';

class FiniteValidator extends KValidator<double> {
  FiniteValidator({required super.message});

  @override
  String? validate(value) {
    if (value == null || value.isInfinite || value.isNaN) return message;

    return null;
  }
}
