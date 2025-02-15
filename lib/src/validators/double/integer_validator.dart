import 'package:keeper/src/validators/validator.dart';

class IntegerValidator extends KValidator<double> {
  IntegerValidator({required super.message});

  @override
  String? validate(value) {
    if (value == null || value % 1 != 0) return message;

    return null;
  }
}
