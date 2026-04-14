part of 'type.dart';

class VDate extends VType<DateTime> {
  final VDateMessages _messages;

  VDate({
    VDateMessages? messages,
    String? requiredMessage,
    String Function(String, String)? invalidTypeMessage,
  }) : _messages = messages ?? const VDateMessages() {
    if (requiredMessage != null) _requiredMessage = requiredMessage;
    if (invalidTypeMessage != null) _invalidTypeMessage = invalidTypeMessage;
  }

  VArray<DateTime> array() => VArray<DateTime>(this);

  VDate after(DateTime date, {String Function(DateTime)? message}) {
    _add(AfterValidator(
      date: date,
      message: message?.call(date) ?? _messages.after(date),
    ));
    return this;
  }

  VDate before(DateTime date, {String Function(DateTime)? message}) {
    _add(BeforeValidator(
      date: date,
      message: message?.call(date) ?? _messages.before(date),
    ));
    return this;
  }

  VDate between(
    DateTime min,
    DateTime max, {
    String Function(DateTime, DateTime)? message,
  }) {
    _add(BetweenDatesValidator(
      min: min,
      max: max,
      message: message?.call(min, max) ?? _messages.between(min, max),
    ));
    return this;
  }

  VDate weekday({String? message}) {
    _add(WeekdayValidator(message: message ?? _messages.weekday));
    return this;
  }

  VDate weekend({String? message}) {
    _add(WeekendValidator(message: message ?? _messages.weekend));
    return this;
  }
}
