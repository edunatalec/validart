import 'package:validart/src/validators/validator.dart';

/// A validator that checks if a given `DateTime` is before a specific date.
///
/// Example usage:
/// ```dart
/// final validator = BeforeValidator(
///   date: DateTime(2025, 1, 1),
///   message: 'The date must be before January 1, 2025',
/// );
///
/// print(validator.validate(DateTime(2024, 12, 31))); // null (valid)
/// print(validator.validate(DateTime(2025, 1, 2))); // 'The date must be before January 1, 2025' (invalid)
/// ```
class BeforeValidator extends ValidatorWithMessage<DateTime> {
  /// The maximum allowed date (exclusive).
  final DateTime date;

  /// Creates a `BeforeValidator` with a required date limit and message.
  BeforeValidator({
    required this.date,
    required super.message,
  });

  @override
  String? validate(covariant DateTime value) {
    return value.isBefore(date) ? null : message;
  }
}
