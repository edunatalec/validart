import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

/// Validates that the age derived from a [DateTime] (treated as a date of
/// birth) falls within the given `[min, max]` range. The comparison is
/// made against `DateTime.now()` at validation time, so the validator
/// stays `const` and reflects the current date on every call.
///
/// ```dart
/// V.date().age(min: 18);          // must be 18 or older
/// V.date().age(min: 18, max: 65); // between 18 and 65
/// V.date().age(max: 120);         // sanity check on claimed birthdate
/// ```
class AgeValidator extends Validator<DateTime> {
  /// Minimum age (in full years). `null` means no lower bound.
  final int? min;

  /// Maximum age (in full years). `null` means no upper bound.
  final int? max;

  /// Creates an [AgeValidator].
  const AgeValidator({this.min, this.max});

  @override
  String get code => VCode.age;

  @override
  Map<String, dynamic>? validate(DateTime value) {
    final age = _calculateAge(value, DateTime.now());

    if (min != null && age < min!) {
      return {'min': min, 'max': max, 'age': age};
    }

    if (max != null && age > max!) {
      return {'min': min, 'max': max, 'age': age};
    }

    return null;
  }

  int _calculateAge(DateTime birth, DateTime now) {
    var years = now.year - birth.year;

    final beforeBirthday = now.month < birth.month ||
        (now.month == birth.month && now.day < birth.day);

    if (beforeBirthday) years--;

    return years;
  }
}
