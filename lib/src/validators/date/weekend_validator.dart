import 'package:validart/src/validators/validator.dart';

/// A validator that checks if a given `DateTime` falls on a weekend (Saturday or Sunday).
///
/// Example usage:
/// ```dart
/// final validator = WeekendValidator(message: 'The date must be a weekend');
///
/// print(validator.validate(DateTime(2025, 2, 15))); // null (Saturday, valid)
/// print(validator.validate(DateTime(2025, 2, 17))); // 'The date must be a weekend' (Monday, invalid)
/// ```
class WeekendValidator extends ValidatorWithMessage<DateTime> {
  /// Creates a `WeekendValidator` instance with a custom error message.
  WeekendValidator({required super.message});

  @override
  String? validate(covariant DateTime value) {
    return [DateTime.saturday, DateTime.sunday].contains(value.weekday)
        ? null
        : message;
  }
}
