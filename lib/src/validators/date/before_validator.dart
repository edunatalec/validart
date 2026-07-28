import '../../v_code.dart';
import '../validator.dart';

/// Validates that a date is before [date].
class BeforeValidator extends Validator<DateTime> {
  /// Creates a [BeforeValidator] with the given [date].
  const BeforeValidator({required this.date});

  /// The date the value must be before.
  final DateTime date;

  @override
  String get code => VDateCode.tooBig;

  @override
  Map<String, dynamic>? validate(DateTime value) =>
      value.isBefore(date) ? null : {'date': date};
}
