import 'package:keeper/src/validators/validator.dart';

class IsFalseValidator extends KValidator<bool> {
  IsFalseValidator({required super.message});

  @override
  String? validate(value) {
    if (value == false) return null;

    return message;
  }
}
