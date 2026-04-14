import 'package:validart/src/validators/validator.dart';

class MaxValidator<T extends num> extends Validator<T> {
  final T max;

  const MaxValidator({required this.max, required super.message});

  @override
  String get code => 'too_big';

  @override
  String? validate(T value) => value <= max ? null : message;
}
