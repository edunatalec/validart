import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

/// Validates that a string is a valid email address.
class EmailValidator extends Validator<String> {
  /// Creates an [EmailValidator].
  const EmailValidator();

  @override
  String get code => VStringCode.email;

  @override
  Map<String, dynamic>? validate(String value) {
    final regex = RegExp(
        r"^(?!.*\.\.)[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+\.[a-zA-Z]{2,}$");
    return regex.hasMatch(value) ? null : {};
  }
}
