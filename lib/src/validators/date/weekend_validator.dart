import 'package:validart/src/validators/validator.dart';

class WeekendValidator extends Validator<DateTime> {
  const WeekendValidator({required super.message});

  @override
  String get code => 'weekend';

  @override
  String? validate(DateTime value) =>
      value.weekday == DateTime.saturday || value.weekday == DateTime.sunday
          ? null
          : message;
}
