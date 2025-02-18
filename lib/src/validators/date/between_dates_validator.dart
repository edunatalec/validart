import 'package:validart/src/validators/validator.dart';

/// A validator that checks if a given `DateTime` falls within a specified date range.
///
/// Example usage:
/// ```dart
/// final validator = BetweenDatesValidator(
///   min: DateTime(2025, 1, 1),
///   max: DateTime(2025, 12, 31),
///   message: 'The date must be between January 1, 2025, and December 31, 2025',
/// );
///
/// print(validator.validate(DateTime(2025, 6, 15))); // null (valid)
/// print(validator.validate(DateTime(2024, 12, 31))); // 'The date must be between...' (invalid)
/// ```
class BetweenDatesValidator extends Validator<DateTime> {
  /// The minimum allowed date (inclusive).
  final DateTime min;

  /// The maximum allowed date (inclusive).
  final DateTime max;

  /// Creates a `BetweenDatesValidator` with a required date range and message.
  BetweenDatesValidator({
    required this.min,
    required this.max,
    required super.message,
  });

  /// Validates if the given [value] is within the specified date range.
  ///
  /// - Returns `null` if the date is **between** `min` and `max` (inclusive).
  /// - Otherwise, returns the error message.
  @override
  String? validate(covariant DateTime value) {
    return (value.isAfter(min.subtract(const Duration(days: 1))) &&
            value.isBefore(max.add(const Duration(days: 1))))
        ? null
        : message;
  }
}
