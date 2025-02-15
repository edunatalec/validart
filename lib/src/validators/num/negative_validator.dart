import 'package:keeper/src/validators/validator.dart';

class NegativeValidator<T extends num> extends KValidator<T> {
  NegativeValidator({required super.message});

  @override
  String? validate(value) {
    if (value == null || value >= 0) return message;

    return null;
  }
}
