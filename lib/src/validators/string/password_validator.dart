import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

class PasswordValidator extends Validator<String> {
  const PasswordValidator();

  @override
  String get code => VCode.password;

  @override
  Map<String, dynamic>? validate(String value) {
    if (value.length < 8) return {};
    if (!RegExp(r'[A-Z]').hasMatch(value)) return {};
    if (!RegExp(r'[a-z]').hasMatch(value)) return {};
    if (!RegExp(r'[0-9]').hasMatch(value)) return {};
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) return {};
    return null;
  }
}
