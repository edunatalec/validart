import 'package:keeper/src/validators/validator.dart';

class IsTrueValidator extends KValidator<bool> {
  IsTrueValidator({required super.message});

  @override
  String? validate(value) {
    if (value == true) return null;

    return message;
  }
}
