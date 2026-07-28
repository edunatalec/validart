import '../../v_code.dart';
import '../validator.dart';

/// Validates that a date is after [date].
class AfterValidator extends Validator<DateTime> {
  /// Creates an [AfterValidator] with the given [date].
  const AfterValidator({required this.date});

  /// The date the value must be after.
  final DateTime date;

  @override
  String get code => VDateCode.tooSmall;

  @override
  Map<String, dynamic>? validate(DateTime value) =>
      value.isAfter(date) ? null : {'date': date};
}
