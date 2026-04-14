import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

class PhoneValidator extends Validator<String> {
  const PhoneValidator();

  @override
  String get code => VCode.invalidPhone;

  @override
  Map<String, dynamic>? validate(String value) {
    final regex = RegExp(r'^\+?[1-9]\d{1,14}$');
    return regex.hasMatch(value) ? null : {};
  }
}
