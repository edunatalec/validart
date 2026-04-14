import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

class MaxValidator<T extends num> extends Validator<T> {
  final T max;

  const MaxValidator({required this.max});

  @override
  String get code => VCode.tooBig;

  @override
  Map<String, dynamic>? validate(T value) => value <= max ? null : {'max': max};
}
