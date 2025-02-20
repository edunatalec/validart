import 'package:validart/src/messages/array_message.dart';
import 'package:validart/src/messages/base_message.dart';

/// A message container for validation errors related to date values.
///
/// The `DateMessage` class provides predefined error messages for date-based
/// validations, such as checking if a date is before or after another date,
/// falls within a range, or occurs on a weekday or weekend.
///
/// ### Example
/// ```dart
/// final dateMessage = DateMessage(
///   after: 'The date must be after the given date',
///   before: 'The date must be before the given date',
///   betweenDates: (min, max) => 'The date must be between ${min.toIso8601String()} and ${max.toIso8601String()}',
///   weekday: 'The date must be a weekday',
///   weekend: 'The date must be a weekend',
/// );
///
/// print(dateMessage.after); // 'The date must be after the given date'
/// print(dateMessage.before); // 'The date must be before the given date'
/// print(dateMessage.betweenDates(DateTime(2025, 1, 1), DateTime(2025, 12, 31)));
/// // 'The date must be between 2025-01-01T00:00:00.000 and 2025-12-31T00:00:00.000'
/// ```
class DateMessage extends BaseMessage {
  /// The error message displayed when a date must be after a specific date.
  ///
  /// Defaults to `'The date must be after the specified date'`.
  final String after;

  /// The error message displayed when a date must be before a specific date.
  ///
  /// Defaults to `'The date must be before the specified date'`.
  final String before;

  /// The error message displayed when a date must be between two specific dates.
  ///
  /// Defaults to `'The date must be between {min} and {max}'`, where `{min}` and `{max}`
  /// are dynamically replaced by the provided date range.
  final String Function(DateTime min, DateTime max) betweenDates;

  /// The error message displayed when a date must be on a weekday (Monday-Friday).
  ///
  /// Defaults to `'The date must be a weekday'`.
  final String weekday;

  /// The error message displayed when a date must be on a weekend (Saturday-Sunday).
  ///
  /// Defaults to `'The date must be a weekend'`.
  final String weekend;

  /// Creates an instance of `DateMessage` with optional custom error messages.
  ///
  /// If no messages are provided, default values will be used.
  DateMessage({
    super.any,
    super.array,
    super.every,
    super.refine,
    super.required,
    String? after,
    String? before,
    String Function(DateTime min, DateTime max)? betweenDates,
    String? weekday,
    String? weekend,
  })  : after = after ?? 'The date must be after the specified date',
        before = before ?? 'The date must be before the specified date',
        betweenDates = betweenDates ??
            ((min, max) =>
                'The date must be between ${min.toIso8601String()} and ${max.toIso8601String()}'),
        weekday = weekday ?? 'The date must be a weekday',
        weekend = weekend ?? 'The date must be a weekend';

  /// Merges the current `DateMessage` instance with a `BaseMessage`,
  /// replacing only the undefined values with those from the base.
  ///
  /// ### Example
  /// ```dart
  /// final baseMessage = BaseMessage(required: 'This field is mandatory');
  /// final dateMessage = DateMessage().mergeWithBase(baseMessage);
  ///
  /// print(dateMessage.required); // Output: 'This field is mandatory'
  /// print(dateMessage.after);    // Output: 'The date must be after the specified date'
  /// ```
  DateMessage mergeWithBase(BaseMessage base) {
    return copyWith(
      any: base.any,
      array: base.array,
      every: base.every,
      refine: base.refine,
      required: base.required,
    );
  }

  /// Creates a copy of the current `DateMessage` instance with updated values.
  ///
  /// If a parameter is not provided, the existing value is retained.
  ///
  /// ### Example
  /// ```dart
  /// final defaultMessage = DateMessage();
  /// final customMessage = defaultMessage.copyWith(after: 'Date should be later than expected');
  /// print(customMessage.after); // Output: 'Date should be later than expected'
  /// ```
  @override
  DateMessage copyWith({
    String? after,
    String? any,
    String? before,
    String Function(DateTime min, DateTime max)? betweenDates,
    String? every,
    String? refine,
    String? required,
    ArrayMessage? array,
    String? weekday,
    String? weekend,
  }) {
    return DateMessage(
      after: after ?? this.after,
      any: any ?? this.any,
      array: array ?? this.array,
      before: before ?? this.before,
      betweenDates: betweenDates ?? this.betweenDates,
      every: every ?? this.every,
      refine: refine ?? this.refine,
      required: required ?? this.required,
      weekday: weekday ?? this.weekday,
      weekend: weekend ?? this.weekend,
    );
  }
}
