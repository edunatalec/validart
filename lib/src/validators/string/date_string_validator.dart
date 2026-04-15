import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

/// Validates that a string is a valid date in `YYYY-MM-DD` format.
class DateStringValidator extends Validator<String> {
  /// Creates a [DateStringValidator].
  const DateStringValidator();

  @override
  String get code => VCode.invalidDate;

  @override
  Map<String, dynamic>? validate(String value) {
    final regex = RegExp(r'^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])$');
    return regex.hasMatch(value) ? null : {};
  }
}
