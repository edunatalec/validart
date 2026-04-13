part of 'type.dart';

class VDate extends VType<DateTime> {
  final VDateMessages _messages;

  VDate([VDateMessages? messages])
      : _messages = messages ?? const VDateMessages();

  VArray<DateTime> array() => VArray<DateTime>(this);

  VDate after(DateTime date, {String Function(DateTime)? message}) {
    final msg = message?.call(date) ?? _messages.after(date);
    _addValidator(
      'too_small',
      (value) => value.isAfter(date) ? null : msg,
    );
    return this;
  }

  VDate before(DateTime date, {String Function(DateTime)? message}) {
    final msg = message?.call(date) ?? _messages.before(date);
    _addValidator(
      'too_big',
      (value) => value.isBefore(date) ? null : msg,
    );
    return this;
  }

  VDate between(
    DateTime min,
    DateTime max, {
    String Function(DateTime, DateTime)? message,
  }) {
    final msg = message?.call(min, max) ?? _messages.between(min, max);
    _addValidator('not_in_range', (value) {
      final afterMin = value.isAfter(min) || value.isAtSameMomentAs(min);
      final beforeMax = value.isBefore(max) || value.isAtSameMomentAs(max);
      return afterMin && beforeMax ? null : msg;
    });
    return this;
  }

  VDate weekday({String? message}) {
    final msg = message ?? _messages.weekday;
    _addValidator('weekday', (value) {
      return value.weekday >= DateTime.monday &&
              value.weekday <= DateTime.friday
          ? null
          : msg;
    });
    return this;
  }

  VDate weekend({String? message}) {
    final msg = message ?? _messages.weekend;
    _addValidator('weekend', (value) {
      return value.weekday == DateTime.saturday ||
              value.weekday == DateTime.sunday
          ? null
          : msg;
    });
    return this;
  }
}
