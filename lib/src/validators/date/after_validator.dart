import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

/// Validates that a date is after [date].
class AfterValidator extends Validator<DateTime> {
  /// The date the value must be after.
  final DateTime date;

  /// Creates an [AfterValidator] with the given [date].
  const AfterValidator({required this.date});

  @override
  String get code => VDateCode.tooSmall;

  @override
  Map<String, dynamic>? validate(DateTime value) =>
      value.isAfter(date) ? null : {'date': date};
}
