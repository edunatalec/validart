import 'package:keeper/src/validators/validator.dart';

class EvenValidator extends KValidator<int> {
  EvenValidator({required super.message});

  @override
  String? validate(int? value) {
    if (value == null || value % 2 != 0) return message;

    return null;
  }
}
