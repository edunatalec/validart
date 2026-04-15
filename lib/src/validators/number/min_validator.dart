import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

class MinValidator<T extends num> extends Validator<T> {
  final T min;

  const MinValidator({required this.min});

  @override
  String get code => VCode.numberTooSmall;

  @override
  Map<String, dynamic>? validate(T value) => value >= min ? null : {'min': min};
}
