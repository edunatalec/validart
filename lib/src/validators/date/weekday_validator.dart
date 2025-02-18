import 'package:validart/src/validators/validator.dart';

/// A validator that checks if a given `DateTime` falls on a weekday (Monday to Friday).
///
/// Example usage:
/// ```dart
/// final validator = WeekdayValidator(message: 'The date must be a weekday');
///
/// print(validator.validate(DateTime(2025, 2, 19))); // null (Wednesday, valid)
/// print(validator.validate(DateTime(2025, 2, 17))); // null (Monday, valid)
/// print(validator.validate(DateTime(2025, 2, 16))); // 'The date must be a weekday' (Sunday, invalid)
/// ```
class WeekdayValidator extends Validator<DateTime> {
  /// Creates a `WeekdayValidator` instance with a custom error message.
  WeekdayValidator({required super.message});

  /// Validates if the given [value] falls on a weekday.
  ///
  /// - Returns `null` if the date is a **Monday to Friday**.
  /// - Otherwise, returns the error message.
  @override
  String? validate(covariant DateTime value) {
    return (value.weekday >= DateTime.monday &&
            value.weekday <= DateTime.friday)
        ? null
        : message;
  }
}
