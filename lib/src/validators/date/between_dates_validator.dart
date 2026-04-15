import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

/// Validates that a date is between [min] and [max] (inclusive).
class BetweenDatesValidator extends Validator<DateTime> {
  /// The earliest allowed date.
  final DateTime min;

  /// The latest allowed date.
  final DateTime max;

  /// Creates a [BetweenDatesValidator] with the given [min] and [max].
  const BetweenDatesValidator({required this.min, required this.max});

  @override
  String get code => VCode.dateNotInRange;

  @override
  Map<String, dynamic>? validate(DateTime value) {
    final isAfterOrAtMin = value.isAfter(min) || value.isAtSameMomentAs(min);
    final isBeforeOrAtMax = value.isBefore(max) || value.isAtSameMomentAs(max);
    return isAfterOrAtMin && isBeforeOrAtMax ? null : {'min': min, 'max': max};
  }
}
