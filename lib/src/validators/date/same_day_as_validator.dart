import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

/// Validates that a [DateTime] falls on the same calendar day as [other],
/// ignoring hour / minute / second. Comparison is by y/m/d only — callers
/// mixing UTC and local time should normalize both ends beforehand.
class SameDayAsValidator extends Validator<DateTime> {
  /// The reference date whose y/m/d the value must match.
  final DateTime other;

  /// Creates a [SameDayAsValidator] with the given reference [other].
  const SameDayAsValidator({required this.other});

  @override
  String get code => VDateCode.sameDay;

  @override
  Map<String, dynamic>? validate(DateTime value) {
    final sameDay = value.year == other.year &&
        value.month == other.month &&
        value.day == other.day;

    return sameDay ? null : {'date': other};
  }
}
