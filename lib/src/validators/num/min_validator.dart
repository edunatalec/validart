import 'package:keeper/src/validators/validator.dart';

class MinValidator<T extends num> extends KValidator<T> {
  final T min;

  MinValidator(this.min, {required super.message});

  @override
  String? validate(value) {
    if (value == null || value < min) return message;

    return null;
  }
}
