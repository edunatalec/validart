import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

class EmailValidator extends Validator<String> {
  const EmailValidator();

  @override
  String get code => VCode.invalidEmail;

  @override
  Map<String, dynamic>? validate(String value) {
    final regex = RegExp(
        r"^(?!.*\.\.)[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+\.[a-zA-Z]{2,}$");
    return regex.hasMatch(value) ? null : {};
  }
}
