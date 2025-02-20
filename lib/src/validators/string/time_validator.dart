import 'package:validart/src/validators/string/pattern_validator.dart';

/// A validator that checks whether a given string is a valid time format.
///
/// The `TimeValidator` ensures that the input follows the standard 24-hour time format.
/// It supports both `HH:mm` (hours and minutes) and `HH:mm:ss` (hours, minutes, and seconds).
///
/// ### Example
/// ```dart
/// final timeValidator = TimeValidator(message: 'Invalid time format');
///
/// print(timeValidator.validate('23:59')); // null (valid)
/// print(timeValidator.validate('12:30')); // null (valid)
/// print(timeValidator.validate('08:45:12')); // null (valid)
/// print(timeValidator.validate('25:00')); // 'Invalid time format' (invalid)
/// print(timeValidator.validate('12:60')); // 'Invalid time format' (invalid)
/// print(timeValidator.validate('invalid-time')); // 'Invalid time format' (invalid)
/// ```
///
/// ## Supported Time Formats:
/// - `HH:mm` → `23:59`, `00:00`, `12:30`
/// - `HH:mm:ss` → `23:59:59`, `08:45:12`
///
/// ### Parameters
/// - [message]: Custom error message when validation fails.
///
/// **Note:** This validator ensures that:
/// - Hours (`HH`) range from `00` to `23`.
/// - Minutes (`mm`) range from `00` to `59`.
/// - Seconds (`ss`) are optional and range from `00` to `59`.
class TimeValidator extends PatternValidator {
  /// Creates a `TimeValidator` to check if a string follows the `HH:mm` or `HH:mm:ss` format.
  ///
  /// - Requires a [message] to specify the validation error.
  TimeValidator({required super.message})
      : super(r'^([01]\d|2[0-3]):([0-5]\d)(?::([0-5]\d))?$');
}
