import '../../v_code.dart';
import '../validator.dart';

/// Validates that a date falls on a weekend (Saturday or Sunday).
class WeekendValidator extends Validator<DateTime> {
  /// Creates a [WeekendValidator].
  const WeekendValidator();

  @override
  String get code => VDateCode.weekend;

  @override
  Map<String, dynamic>? validate(DateTime value) =>
      value.weekday == DateTime.saturday || value.weekday == DateTime.sunday
          ? null
          : {};
}
