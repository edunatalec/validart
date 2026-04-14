import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

class WeekendValidator extends Validator<DateTime> {
  const WeekendValidator();

  @override
  String get code => VCode.weekend;

  @override
  Map<String, dynamic>? validate(DateTime value) =>
      value.weekday == DateTime.saturday || value.weekday == DateTime.sunday
          ? null
          : {};
}
