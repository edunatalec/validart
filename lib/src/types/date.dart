import 'package:validart/src/messages/date_message.dart';
import 'package:validart/src/types/primitive.dart';
import 'package:validart/src/types/array.dart';
import 'package:validart/src/validators/date/after_validator.dart';
import 'package:validart/src/validators/date/before_validator.dart';
import 'package:validart/src/validators/date/between_dates_validator.dart';
import 'package:validart/src/validators/date/weekday_validator.dart';
import 'package:validart/src/validators/date/weekend_validator.dart';
import 'package:validart/src/validators/required_validator.dart';
import 'package:validart/src/validators/validator.dart';

/// A validation class for `DateTime` values in Validart.
///
/// The `VDate` class provides validation for date-based constraints, including:
/// - Required validation
/// - Date comparisons (`before`, `after`, `betweenDates`)
/// - Day type validation (`weekday`, `weekend`)
///
/// ### Example
/// ```dart
/// final validator = v.date().after(DateTime(2024, 1, 1));
///
/// print(validator.validate(DateTime(2025, 1, 1))); // true
/// print(validator.validate(DateTime(2023, 12, 31))); // false
/// ```
class VDate extends VPrimitive<DateTime> {
  /// The validation messages used for date-related errors.
  final DateMessage _message;

  /// Creates an instance of `VDate` with optional custom validation messages.
  ///
  /// This constructor initializes the date validator and automatically applies
  /// a `RequiredValidator` to ensure that the date is not null unless marked as optional.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.date();
  ///
  /// print(validator.validate(DateTime.now())); // true (valid)
  /// print(validator.validate(null)); // 'Date is required' (invalid)
  /// ```
  ///
  /// ### Parameters
  /// - [_message]: The validation messages used for error handling.
  /// - [message]: *(optional)* A custom error message for required validation.
  ///
  /// ### Behavior
  /// By default, this validator requires a date value. To allow `null` values,
  /// use the `.optional()` or `.nullable()` method.
  VDate(this._message, {required String? message}) {
    add(RequiredValidator(message: message ?? _message.required));
  }

  /// Ensures that the date is after the specified `date`.
  ///
  /// This method adds an `AfterValidator` to check whether the provided date
  /// occurs after the given reference date.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.date().after(DateTime(2024, 01, 01));
  ///
  /// print(validator.validate(DateTime(2024, 06, 01))); // true (valid)
  /// print(validator.validate(DateTime(2023, 12, 31))); // 'Date must be after 2024-01-01' (invalid)
  /// ```
  ///
  /// ### Parameters
  /// - [date]: The reference date that the validated date must be after.
  /// - [message]: *(optional)* A custom error message for validation failure.
  ///
  /// ### Returns
  /// The current `VDate` instance with the `after` validation applied.
  VDate after(DateTime date, {String? message}) {
    return add(AfterValidator(date: date, message: message ?? _message.after));
  }

  /// Ensures that the date is before the specified `date`.
  ///
  /// This method adds a `BeforeValidator` to check whether the provided date
  /// occurs before the given reference date.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.date().before(DateTime(2025, 01, 01));
  ///
  /// print(validator.validate(DateTime(2024, 06, 01))); // true (valid)
  /// print(validator.validate(DateTime(2025, 02, 01))); // 'Date must be before 2025-01-01' (invalid)
  /// ```
  ///
  /// ### Parameters
  /// - [date]: The reference date that the validated date must be before.
  /// - [message]: *(optional)* A custom error message for validation failure.
  ///
  /// ### Returns
  /// The current `VDate` instance with the `before` validation applied.
  VDate before(DateTime date, {String? message}) {
    return add(BeforeValidator(
      date: date,
      message: message ?? _message.before,
    ));
  }

  /// Ensures that the date falls within the specified range (`min` to `max`).
  ///
  /// This method adds a `BetweenDatesValidator` to check whether the date
  /// is within the given date range, inclusive.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.date().betweenDates(
  ///   DateTime(2024, 01, 01),
  ///   DateTime(2025, 12, 31),
  /// );
  ///
  /// print(validator.validate(DateTime(2024, 06, 01))); // true (valid)
  /// print(validator.validate(DateTime(2026, 01, 01))); // 'Date must be between 2024-01-01 and 2025-12-31' (invalid)
  /// ```
  ///
  /// ### Parameters
  /// - [min]: The minimum allowed date.
  /// - [max]: The maximum allowed date.
  /// - [message]: *(optional)* A custom error message, which can be dynamically generated
  ///   using a function that receives the `min` and `max` dates.
  ///
  /// ### Returns
  /// The current `VDate` instance with the `betweenDates` validation applied.
  VDate betweenDates(
    DateTime min,
    DateTime max, {
    String Function(DateTime min, DateTime max)? message,
  }) {
    return add(BetweenDatesValidator(
      min: min,
      max: max,
      message: message?.call(min, max) ?? _message.betweenDates(min, max),
    ));
  }

  /// Ensures that the date falls on a weekday (Monday to Friday).
  ///
  /// This method adds a `WeekdayValidator` to check whether the given date
  /// is a weekday, excluding weekends (Saturday and Sunday).
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.date().weekday();
  ///
  /// print(validator.validate(DateTime(2024, 06, 03))); // true (Monday)
  /// print(validator.validate(DateTime(2024, 06, 08))); // 'Date must be a weekday' (invalid - Saturday)
  /// ```
  ///
  /// ### Parameters
  /// - [message]: *(optional)* A custom error message.
  ///
  /// ### Returns
  /// The current `VDate` instance with the `weekday` validation applied.
  VDate weekday({String? message}) {
    return add(WeekdayValidator(message: message ?? _message.weekday));
  }

  /// Ensures that the date falls on a weekend (Saturday or Sunday).
  ///
  /// This method adds a `WeekendValidator` to check whether the given date
  /// is a weekend day (Saturday or Sunday), excluding weekdays (Monday to Friday).
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.date().weekend();
  ///
  /// print(validator.validate(DateTime(2024, 06, 08))); // true (Saturday)
  /// print(validator.validate(DateTime(2024, 06, 03))); // 'Date must be a weekend' (invalid - Monday)
  /// ```
  ///
  /// ### Parameters
  /// - [message]: *(optional)* A custom error message.
  ///
  /// ### Returns
  /// The current `VDate` instance with the `weekend` validation applied.
  VDate weekend({String? message}) {
    return add(WeekendValidator(message: message ?? _message.weekend));
  }

  /// Adds a custom validator to the `VDate` instance.
  ///
  /// This method allows adding additional validation rules for date values,
  /// enabling more flexible and specific constraints.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.date().add(MyCustomDateValidator());
  ///
  /// print(validator.validate(DateTime.now())); // Validation depends on custom logic
  /// ```
  ///
  /// ### Parameters
  /// - [validator]: A custom validator that extends `Validator<DateTime>`.
  ///
  /// ### Returns
  /// The current `VDate` instance with the added validator.
  @override
  VDate add(Validator<DateTime> validator) {
    super.add(validator);
    return this;
  }

  /// Ensures that the date matches **at least one** of the provided `VDate` validators.
  ///
  /// This method checks if the date satisfies at least one of the specified validation rules.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.date().any([
  ///   v.date().after(DateTime(2025, 1, 1)),
  ///   v.date().before(DateTime(2020, 12, 31))
  /// ]);
  ///
  /// print(validator.validate(DateTime(2026, 1, 1))); // true (passes "after" validation)
  /// print(validator.validate(DateTime(2019, 1, 1))); // true (passes "before" validation)
  /// print(validator.validate(DateTime(2022, 1, 1))); // false (matches neither condition)
  /// ```
  ///
  /// ### Parameters
  /// - [types]: A list of `VDate` validators to check against.
  /// - [message] *(optional)*: A custom validation message if the value does not match any validator.
  ///
  /// ### Returns
  /// The current `VDate` instance with the `any` validation applied.
  @override
  VDate any(covariant List<VDate> types, {String? message}) {
    super.any(types, message: message ?? _message.any);
    return this;
  }

  /// Creates an array validator (`VArray<DateTime>`) for validating lists of date values.
  ///
  /// This method enables validation of arrays where each element is a `DateTime`,
  /// applying the same validation rules defined for the individual date validator.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.date().array();
  ///
  /// print(validator.validate([
  ///   DateTime(2025, 6, 15),
  ///   DateTime(2024, 12, 31)
  /// ])); // true (valid)
  ///
  /// print(validator.validate([
  ///   DateTime(2025, 6, 15),
  ///   "invalid date"
  /// ])); // false (invalid)
  /// ```
  ///
  /// ### Parameters
  /// - [message] *(optional)*: A custom validation message for array validation errors.
  ///
  /// ### Returns
  /// A `VArray<DateTime>` instance for validating lists of date values.
  @override
  VArray<DateTime> array({String? message}) {
    return VArray<DateTime>(this, _message.array, message: message);
  }

  /// Ensures that the date matches **all** of the provided `VDate` validators.
  ///
  /// This method checks if the date satisfies every specified validation rule.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.date().every([
  ///   v.date().after(DateTime(2020, 1, 1)),
  ///   v.date().before(DateTime(2030, 12, 31))
  /// ]);
  ///
  /// print(validator.validate(DateTime(2025, 6, 15))); // true (passes both conditions)
  /// print(validator.validate(DateTime(2019, 12, 31))); // false (fails "after" validation)
  /// print(validator.validate(DateTime(2035, 1, 1))); // false (fails "before" validation)
  /// ```
  ///
  /// ### Parameters
  /// - [types]: A list of `VDate` validators to check against.
  /// - [message] *(optional)*: A custom validation message if the value does not match all validators.
  ///
  /// ### Returns
  /// The current `VDate` instance with the `every` validation applied.
  @override
  VDate every(covariant List<VDate> types, {String? message}) {
    super.every(types, message: message ?? _message.every);
    return this;
  }

  /// Marks the date as optional, but this method has no effect.
  ///
  /// Unlike other data types, a `DateTime` value cannot be "optional" in the traditional sense.
  /// The `.nullable()` method should be used instead if `null` values are allowed.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.date().optional(); // No effect
  ///
  /// print(validator.validate(null)); // false (optional does not apply to DateTime)
  /// print(validator.validate(DateTime(2025, 6, 15))); // true
  /// ```
  ///
  /// ### Returns
  /// The current `VDate` instance (without modifying its behavior).
  @override
  VDate optional() {
    super.optional();
    return this;
  }

  /// Marks the date as nullable, allowing `null` as a valid value.
  ///
  /// When this method is applied, the validation will pass if the value is `null`,
  /// otherwise, all other validation rules will be checked.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.date().nullable();
  ///
  /// print(validator.validate(null)); // true (valid)
  /// print(validator.validate(DateTime(2025, 6, 15))); // true (valid)
  /// ```
  ///
  /// ### Returns
  /// The current `VDate` instance with the `nullable` flag enabled.
  @override
  VDate nullable() {
    super.nullable();
    return this;
  }

  /// Applies a custom validation function to the `DateTime` value.
  ///
  /// This method allows defining a custom validation rule using a function
  /// that evaluates the `DateTime` value and returns `true` if valid.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.date().refine(
  ///   (date) => date.isAfter(DateTime(2020, 1, 1)),
  ///   message: "Date must be after January 1, 2020",
  /// );
  ///
  /// print(validator.validate(DateTime(2025, 6, 15))); // true (valid)
  /// print(validator.validate(DateTime(2019, 12, 31))); // false (invalid)
  /// ```
  ///
  /// ### Parameters
  /// - [validator]: A function that takes a `DateTime` and returns `true` if valid.
  /// - [message] *(optional)*: A custom validation message.
  ///
  /// ### Returns
  /// The current `VDate` instance with the custom validation applied.
  @override
  VDate refine(bool Function(DateTime data) validator, {String? message}) {
    super.refine(validator, message: message ?? _message.refine);
    return this;
  }
}
