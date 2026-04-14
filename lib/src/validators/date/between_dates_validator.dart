import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

class BetweenDatesValidator extends Validator<DateTime> {
  final DateTime min;
  final DateTime max;

  const BetweenDatesValidator({required this.min, required this.max});

  @override
  String get code => VCode.notInRange;

  @override
  Map<String, dynamic>? validate(DateTime value) {
    final isAfterOrAtMin = value.isAfter(min) || value.isAtSameMomentAs(min);
    final isBeforeOrAtMax = value.isBefore(max) || value.isAtSameMomentAs(max);
    return isAfterOrAtMin && isBeforeOrAtMax ? null : {'min': min, 'max': max};
  }
}
