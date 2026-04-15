import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

class MaxLengthListValidator<T> extends Validator<List<T>> {
  final int max;

  const MaxLengthListValidator({required this.max});

  @override
  String get code => VCode.arrayTooBig;

  @override
  Map<String, dynamic>? validate(List<T> value) =>
      value.length <= max ? null : {'max': max};
}
