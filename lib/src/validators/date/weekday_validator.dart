import 'package:validart/src/validators/validator.dart';

class WeekdayValidator extends Validator<DateTime> {
  const WeekdayValidator({required super.message});

  @override
  String get code => 'weekday';

  @override
  String? validate(DateTime value) =>
      value.weekday >= DateTime.monday && value.weekday <= DateTime.friday
          ? null
          : message;
}
