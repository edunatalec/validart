import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

class LengthValidator extends Validator<String> {
  final int length;

  const LengthValidator({required this.length});

  @override
  String get code => VCode.stringLength;

  @override
  Map<String, dynamic>? validate(String value) =>
      value.length == length ? null : {'length': length};
}
