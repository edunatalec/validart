import 'package:validart/src/validators/validator.dart';

class PhoneValidator extends Validator<String> {
  const PhoneValidator({required super.message});

  @override
  String get code => 'invalid_phone';

  @override
  String? validate(String value) {
    final regex = RegExp(r'^\+?[1-9]\d{1,14}$');
    return regex.hasMatch(value) ? null : message;
  }
}
