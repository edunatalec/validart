import 'package:validart/src/validators/validator.dart';

class BetweenDatesValidator extends Validator<DateTime> {
  final DateTime min;
  final DateTime max;

  const BetweenDatesValidator(
      {required this.min, required this.max, required super.message});

  @override
  String get code => 'not_in_range';

  @override
  String? validate(DateTime value) {
    final isAfterOrAtMin = value.isAfter(min) || value.isAtSameMomentAs(min);
    final isBeforeOrAtMax = value.isBefore(max) || value.isAtSameMomentAs(max);
    return isAfterOrAtMin && isBeforeOrAtMax ? null : message;
  }
}
