import 'package:validart/src/validators/validator.dart';

/// A validator that checks if a given `DateTime` is after a specific date.
///
/// Example usage:
/// ```dart
/// final validator = AfterValidator(
///   date: DateTime(2025, 1, 1),
///   message: 'The date must be after January 1, 2025',
/// );
///
/// print(validator.validate(DateTime(2025, 1, 2))); // null (valid)
/// print(validator.validate(DateTime(2024, 12, 31))); // 'The date must be after January 1, 2025' (invalid)
/// ```
class AfterValidator extends ValidatorWithMessage<DateTime> {
  /// The minimum allowed date (exclusive).
  final DateTime date;

  /// Creates an `AfterValidator` with a required date limit and message.
  AfterValidator({
    required this.date,
    required super.message,
  });

  @override
  String? validate(covariant DateTime value) {
    return value.isAfter(date) ? null : message;
  }
}
