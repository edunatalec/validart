part of 'type.dart';

/// Validates [DateTime] values.
///
/// ```dart
/// final schema = V.date().after(DateTime(2024));
/// schema.parse(DateTime(2025)); // DateTime(2025)
/// ```
class VDate extends VType<DateTime> {
  /// Creates a [VDate]. Pass [message] to override the default
  /// translation used when the input is `null`.
  VDate({super.message});

  @override
  VDate add(
    Validator<DateTime> validator, {
    String? message,
    List<Object>? path,
  }) {
    super.add(validator, message: message, path: path);
    return this;
  }

  @override
  VDate nullable() {
    super.nullable();
    return this;
  }

  @override
  VDate defaultValue(DateTime value) {
    super.defaultValue(value);
    return this;
  }

  @override
  VDate preprocess(Object? Function(Object? value) fn) {
    super.preprocess(fn);
    return this;
  }

  @override
  VDate refine(
    bool Function(DateTime value) check, {
    String? message,
    String? code,
  }) {
    super.refine(check, message: message, code: code);
    return this;
  }

  @override
  VDate preprocessAsync(Future<Object?> Function(Object? value) fn) {
    super.preprocessAsync(fn);
    return this;
  }

  @override
  VDate refineAsync(
    Future<bool> Function(DateTime value) check, {
    String? message,
    String? code,
    Duration? timeout,
  }) {
    super.refineAsync(check, message: message, code: code, timeout: timeout);
    return this;
  }

  /// Creates a [VArray] schema that validates a `List<DateTime>`.
  ///
  /// ```dart
  /// V.date().array().parse([DateTime(2024), DateTime(2025)]);
  /// ```
  VArray<DateTime> array() => VArray<DateTime>(this);

  /// Validates that the date is after [date].
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.date().after(DateTime(2024)).validate(DateTime(2025)); // true
  /// V.date().after(DateTime(2024)).validate(DateTime(2023)); // false
  /// ```
  VDate after(DateTime date, {String Function(DateTime)? message}) {
    return add(AfterValidator(date: date), message: message?.call(date));
  }

  /// Validates that the date is before [date].
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.date().before(DateTime(2025)).validate(DateTime(2024)); // true
  /// V.date().before(DateTime(2025)).validate(DateTime(2026)); // false
  /// ```
  VDate before(DateTime date, {String Function(DateTime)? message}) {
    return add(BeforeValidator(date: date), message: message?.call(date));
  }

  /// Validates that the date is between [min] and [max] (inclusive).
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.date().between(DateTime(2024), DateTime(2026))
  ///   .validate(DateTime(2025)); // true
  /// ```
  VDate between(
    DateTime min,
    DateTime max, {
    String Function(DateTime, DateTime)? message,
  }) {
    return add(
      BetweenDatesValidator(min: min, max: max),
      message: message?.call(min, max),
    );
  }

  /// Validates that the date falls on a weekday (Monday–Friday).
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.date().weekday().validate(DateTime(2024, 1, 15)); // true (Monday)
  /// V.date().weekday().validate(DateTime(2024, 1, 14)); // false (Sunday)
  /// ```
  VDate weekday({String? message}) {
    return add(const WeekdayValidator(), message: message);
  }

  /// Validates that the date falls on a weekend (Saturday–Sunday).
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.date().weekend().validate(DateTime(2024, 1, 14)); // true (Sunday)
  /// V.date().weekend().validate(DateTime(2024, 1, 15)); // false (Monday)
  /// ```
  VDate weekend({String? message}) {
    return add(const WeekendValidator(), message: message);
  }

  /// Validates that the age derived from the value (treated as a date of
  /// birth) falls within the given range. Age is computed against
  /// `DateTime.now()` at validation time.
  ///
  /// At least one of [min]/[max] must be provided.
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.date().age(min: 18);                  // 18+
  /// V.date().age(min: 18, max: 65);         // between 18 and 65
  /// V.date().age(max: 120);                 // at most 120
  /// ```
  VDate age({int? min, int? max, String? message}) {
    assert(
      min != null || max != null,
      'At least one of min or max must be provided.',
    );

    return add(AgeValidator(min: min, max: max), message: message);
  }
}
