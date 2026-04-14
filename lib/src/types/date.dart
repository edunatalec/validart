part of 'type.dart';

class VDate extends VType<DateTime> {
  VArray<DateTime> array() => VArray<DateTime>(this);

  VDate after(DateTime date, {String Function(DateTime)? message}) {
    add(AfterValidator(date: date), message: message?.call(date));
    return this;
  }

  VDate before(DateTime date, {String Function(DateTime)? message}) {
    add(BeforeValidator(date: date), message: message?.call(date));
    return this;
  }

  VDate between(
    DateTime min,
    DateTime max, {
    String Function(DateTime, DateTime)? message,
  }) {
    add(
      BetweenDatesValidator(min: min, max: max),
      message: message?.call(min, max),
    );
    return this;
  }

  VDate weekday({String? message}) {
    add(const WeekdayValidator(), message: message);
    return this;
  }

  VDate weekend({String? message}) {
    add(const WeekendValidator(), message: message);
    return this;
  }
}
