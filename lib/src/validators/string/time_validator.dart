import 'package:validart/src/validators/validator.dart';

class TimeValidator extends Validator<String> {
  const TimeValidator({required super.message});

  @override
  String get code => 'invalid_time';

  @override
  String? validate(String value) {
    final regex = RegExp(r'^([01]\d|2[0-3]):[0-5]\d(:[0-5]\d)?$');
    return regex.hasMatch(value) ? null : message;
  }
}
