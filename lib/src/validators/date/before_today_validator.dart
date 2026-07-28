import '../../v_code.dart';
import '../validator.dart';

/// Validates that a [DateTime] is strictly before today (y/m/d comparison
/// against `DateTime.now()` in local time). The current calendar day is
/// **not** accepted.
class BeforeTodayValidator extends Validator<DateTime> {
  /// Creates a [BeforeTodayValidator].
  const BeforeTodayValidator();

  @override
  String get code => VDateCode.beforeToday;

  @override
  Map<String, dynamic>? validate(DateTime value) {
    final now = DateTime.now();
    final valueDay = DateTime(value.year, value.month, value.day);
    final today = DateTime(now.year, now.month, now.day);

    return valueDay.isBefore(today) ? null : {};
  }
}
