import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

class TimeValidator extends Validator<String> {
  const TimeValidator();

  @override
  String get code => VCode.invalidTime;

  @override
  Map<String, dynamic>? validate(String value) {
    final regex = RegExp(r'^([01]\d|2[0-3]):[0-5]\d(:[0-5]\d)?$');
    return regex.hasMatch(value) ? null : {};
  }
}
