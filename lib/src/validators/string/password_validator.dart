import 'package:validart/src/validators/validator.dart';

class PasswordValidator extends Validator<String> {
  const PasswordValidator({required super.message});

  @override
  String get code => 'password';

  @override
  String? validate(String value) {
    if (value.length < 8) return message;
    if (!RegExp(r'[A-Z]').hasMatch(value)) return message;
    if (!RegExp(r'[a-z]').hasMatch(value)) return message;
    if (!RegExp(r'[0-9]').hasMatch(value)) return message;
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) return message;
    return null;
  }
}
