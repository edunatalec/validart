import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

class MinLengthListValidator<T> extends Validator<List<T>> {
  final int min;

  const MinLengthListValidator({required this.min});

  @override
  String get code => VCode.tooSmall;

  @override
  Map<String, dynamic>? validate(List<T> value) =>
      value.length >= min ? null : {'min': min};
}
