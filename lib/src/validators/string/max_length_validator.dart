import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

class MaxLengthValidator extends Validator<String> {
  final int max;

  const MaxLengthValidator({required this.max});

  @override
  String get code => VCode.tooBig;

  @override
  Map<String, dynamic>? validate(String value) =>
      value.length <= max ? null : {'max': max};
}
