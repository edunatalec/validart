import '../../v_code.dart';
import '../validator.dart';

/// Validates that a [DateTime] is strictly after today (y/m/d comparison
/// against `DateTime.now()` in local time). The current calendar day is
/// **not** accepted — use `isToday()` for "today or later" via composition
/// in a union, or `afterToday()` followed by `isToday()` on a separate
/// branch.
class AfterTodayValidator extends Validator<DateTime> {
  /// Creates an [AfterTodayValidator].
  const AfterTodayValidator();

  @override
  String get code => VDateCode.afterToday;

  @override
  Map<String, dynamic>? validate(DateTime value) {
    final now = DateTime.now();
    final valueDay = DateTime(value.year, value.month, value.day);
    final today = DateTime(now.year, now.month, now.day);

    return valueDay.isAfter(today) ? null : {};
  }
}
