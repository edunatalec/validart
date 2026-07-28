import '../../v_code.dart';
import '../validator.dart';

/// Validates that a [DateTime] falls on the current calendar day, ignoring
/// hour / minute / second. The comparison is against `DateTime.now()` at
/// validation time and uses local time — callers operating in UTC should
/// normalize the input beforehand.
class IsTodayValidator extends Validator<DateTime> {
  /// Creates an [IsTodayValidator].
  const IsTodayValidator();

  @override
  String get code => VDateCode.isToday;

  @override
  Map<String, dynamic>? validate(DateTime value) {
    final now = DateTime.now();

    final sameDay = value.year == now.year &&
        value.month == now.month &&
        value.day == now.day;

    return sameDay ? null : {};
  }
}
