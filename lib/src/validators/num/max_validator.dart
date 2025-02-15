import 'package:keeper/src/validators/validator.dart';

class MaxValidator<T extends num> extends KValidator<T> {
  final T max;

  MaxValidator(this.max, {required super.message});

  @override
  String? validate(value) {
    if (value == null || value > max) return message;

    return null;
  }
}
