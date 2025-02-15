import 'package:keeper/src/validators/validator.dart';

class BetweenValidator<T extends num> extends KValidator<T> {
  final T min;
  final T max;

  BetweenValidator(this.min, this.max, {required super.message});

  @override
  String? validate(value) {
    if (value == null) return message;
    if (value < min || value > max) return message;

    return null;
  }
}
