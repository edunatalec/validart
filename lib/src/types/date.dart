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
  VDate({super.message, super.invalidTypeMessage});

  @override
  String get typeName => 'date';

  @override
  VDate add(
    Validator<DateTime> validator, {
    String? message,
    List<Object>? path,
    Set<String>? dependsOn,
  }) {
    super.add(validator, message: message, path: path, dependsOn: dependsOn);
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
    Set<String>? dependsOn,
  }) {
    super.refine(check, message: message, code: code, dependsOn: dependsOn);
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
    Set<String>? dependsOn,
  }) {
    super.refineAsync(
      check,
      message: message,
      code: code,
      timeout: timeout,
      dependsOn: dependsOn,
    );
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

  /// Validates that the value falls on the current calendar day.
  ///
  /// Compares y/m/d only — hour/minute/second are ignored, so any
  /// `DateTime` whose date part equals today's date passes. Resolved
  /// against `DateTime.now()` at validation time in **local time**.
  /// Callers operating in UTC should normalize the input first.
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.date().isToday().validate(DateTime.now()); // true
  /// V.date().isToday().validate(DateTime.now().add(const Duration(days: 1))); // false
  /// ```
  VDate isToday({String? message}) =>
      add(const IsTodayValidator(), message: message);

  /// Validates that the value falls on the same calendar day as [other],
  /// ignoring hour/minute/second.
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// final reference = DateTime(2026, 5, 16, 14, 0);
  /// V.date().sameDayAs(reference).validate(DateTime(2026, 5, 16, 9, 30)); // true
  /// V.date().sameDayAs(reference).validate(DateTime(2026, 5, 17));         // false
  /// ```
  VDate sameDayAs(DateTime other, {String Function(DateTime)? message}) {
    return add(
      SameDayAsValidator(other: other),
      message: message?.call(other),
    );
  }

  /// Validates that the value is strictly after today (y/m/d comparison).
  ///
  /// "Today" itself is rejected — combine with [isToday] (e.g. in a
  /// [VUnion]) when you want "today or any future day". Resolved against
  /// `DateTime.now()` in local time.
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.date().afterToday()
  ///   .validate(DateTime.now().add(const Duration(days: 1))); // true
  /// V.date().afterToday().validate(DateTime.now());            // false
  /// ```
  VDate afterToday({String? message}) =>
      add(const AfterTodayValidator(), message: message);

  /// Validates that the value is strictly before today (y/m/d comparison).
  ///
  /// "Today" itself is rejected — combine with [isToday] when you need
  /// "today or any past day". Resolved against `DateTime.now()` in local
  /// time.
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.date().beforeToday()
  ///   .validate(DateTime.now().subtract(const Duration(days: 1))); // true
  /// V.date().beforeToday().validate(DateTime.now());                // false
  /// ```
  VDate beforeToday({String? message}) =>
      add(const BeforeTodayValidator(), message: message);
}
