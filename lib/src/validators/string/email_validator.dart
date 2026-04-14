import 'package:validart/src/validators/validator.dart';

class EmailValidator extends Validator<String> {
  const EmailValidator({required super.message});

  @override
  String get code => 'invalid_email';

  @override
  String? validate(String value) {
    final regex = RegExp(
        r"^(?!.*\.\.)[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+\.[a-zA-Z]{2,}$");
    return regex.hasMatch(value) ? null : message;
  }
}
