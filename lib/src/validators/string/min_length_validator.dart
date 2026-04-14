import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

class MinLengthValidator extends Validator<String> {
  final int min;

  const MinLengthValidator({required this.min});

  @override
  String get code => VCode.tooSmall;

  @override
  Map<String, dynamic>? validate(String value) =>
      value.length >= min ? null : {'min': min};
}
