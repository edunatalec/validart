import '../../v_code.dart';
import '../validator.dart';

/// Validates that a date falls on a weekday (Monday through Friday).
class WeekdayValidator extends Validator<DateTime> {
  /// Creates a [WeekdayValidator].
  const WeekdayValidator();

  @override
  String get code => VDateCode.weekday;

  @override
  Map<String, dynamic>? validate(DateTime value) =>
      value.weekday >= DateTime.monday && value.weekday <= DateTime.friday
          ? null
          : {};
}
