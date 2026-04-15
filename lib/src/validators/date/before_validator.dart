import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

/// Validates that a date is before [date].
class BeforeValidator extends Validator<DateTime> {
  /// The date the value must be before.
  final DateTime date;

  /// Creates a [BeforeValidator] with the given [date].
  const BeforeValidator({required this.date});

  @override
  String get code => VCode.dateTooBig;

  @override
  Map<String, dynamic>? validate(DateTime value) =>
      value.isBefore(date) ? null : {'date': date};
}
