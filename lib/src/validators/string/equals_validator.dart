import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

class EqualsValidator extends Validator<String> {
  final String expected;

  const EqualsValidator({required this.expected});

  @override
  String get code => VCode.equals;

  @override
  Map<String, dynamic>? validate(String value) =>
      value == expected ? null : {'expected': expected};
}
