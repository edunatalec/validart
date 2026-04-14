import 'package:validart/src/validators/validator.dart';

class MinValidator<T extends num> extends Validator<T> {
  final T min;

  const MinValidator({required this.min, required super.message});

  @override
  String get code => 'too_small';

  @override
  String? validate(T value) => value >= min ? null : message;
}
