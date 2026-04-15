import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

/// Validates that a string is a valid phone number in E.164 format.
class PhoneValidator extends Validator<String> {
  /// Creates a [PhoneValidator].
  const PhoneValidator();

  @override
  String get code => VCode.invalidPhone;

  @override
  Map<String, dynamic>? validate(String value) {
    final regex = RegExp(r'^\+?[1-9]\d{1,14}$');
    return regex.hasMatch(value) ? null : {};
  }
}
