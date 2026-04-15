import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

class BetweenValidator<T extends num> extends Validator<T> {
  final T min;
  final T max;

  const BetweenValidator({
    required this.min,
    required this.max,
  });

  @override
  String get code => VCode.numberNotInRange;

  @override
  Map<String, dynamic>? validate(T value) =>
      value >= min && value <= max ? null : {'min': min, 'max': max};
}
