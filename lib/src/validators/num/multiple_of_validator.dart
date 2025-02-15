import 'package:keeper/src/validators/validator.dart';

class MultipleOfValidator<T extends num> extends KValidator<T> {
  final T factor;

  MultipleOfValidator(this.factor, {required super.message});

  @override
  String? validate(value) {
    if (value == null || value % factor != 0) return message;

    return null;
  }
}
