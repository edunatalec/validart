import 'package:validart/src/validators/validator.dart';

class DateStringValidator extends Validator<String> {
  const DateStringValidator({required super.message});

  @override
  String get code => 'invalid_date';

  @override
  String? validate(String value) {
    final regex = RegExp(r'^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])$');
    return regex.hasMatch(value) ? null : message;
  }
}
