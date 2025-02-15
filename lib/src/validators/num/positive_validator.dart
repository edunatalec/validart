import 'package:keeper/src/validators/validator.dart';

class PositiveValidator<T extends num> extends KValidator<T> {
  PositiveValidator({required super.message});

  @override
  String? validate(value) {
    if (value == null || value <= 0) return message;

    return null;
  }
}
