import 'package:keeper/src/validators/validator.dart';

class DecimalValidator extends KValidator<double> {
  DecimalValidator({required super.message});

  @override
  String? validate(value) {
    if (value == null || value % 1 == 0) return message;

    return null;
  }
}
