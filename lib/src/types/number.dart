part of 'type.dart';

abstract class VNumber<T extends num> extends VType<T> {
  VNumberMessages get _messages;

  VNumber<T> min(T value, {String Function(T)? message}) {
    final msg = message?.call(value) ?? _messages.min(value);
    _addValidator('too_small', (v) => v >= value ? null : msg);
    return this;
  }

  VNumber<T> max(T value, {String Function(T)? message}) {
    final msg = message?.call(value) ?? _messages.max(value);
    _addValidator('too_big', (v) => v <= value ? null : msg);
    return this;
  }

  VNumber<T> positive({String? message}) {
    final msg = message ?? _messages.positive;
    _addValidator('positive', (v) => v > 0 ? null : msg);
    return this;
  }

  VNumber<T> negative({String? message}) {
    final msg = message ?? _messages.negative;
    _addValidator('negative', (v) => v < 0 ? null : msg);
    return this;
  }

  VNumber<T> between(T min, T max, {String Function(T, T)? message}) {
    final msg = message?.call(min, max) ?? _messages.between(min, max);
    _addValidator('not_in_range', (v) => v >= min && v <= max ? null : msg);
    return this;
  }

  VNumber<T> multipleOf(T factor, {String Function(T)? message}) {
    final msg = message?.call(factor) ?? _messages.multipleOf(factor);
    _addValidator('multiple_of', (v) => v % factor == 0 ? null : msg);
    return this;
  }
}

class VInt extends VNumber<int> {
  @override
  final VNumberMessages _messages;

  VInt([VNumberMessages? messages])
      : _messages = messages ?? const VNumberMessages();

  VInt even({String? message}) {
    final msg = message ?? _messages.even;
    _addValidator('even', (v) => v % 2 == 0 ? null : msg);
    return this;
  }

  VInt odd({String? message}) {
    final msg = message ?? _messages.odd;
    _addValidator('odd', (v) => v % 2 != 0 ? null : msg);
    return this;
  }

  VInt prime({String? message}) {
    final msg = message ?? _messages.prime;
    _addValidator('prime', (v) {
      if (v <= 1) return msg;
      for (int i = 2; i <= math.sqrt(v).toInt(); i++) {
        if (v % i == 0) return msg;
      }
      return null;
    });
    return this;
  }

  VArray<int> array() => VArray<int>(this);
}

class VDouble extends VNumber<double> {
  @override
  final VNumberMessages _messages;

  VDouble([VNumberMessages? messages])
      : _messages = messages ?? const VNumberMessages();

  VDouble finite({String? message}) {
    final msg = message ?? _messages.finite;
    _addValidator(
      'finite',
      (v) => !v.isInfinite && !v.isNaN ? null : msg,
    );
    return this;
  }

  VDouble decimal({String? message}) {
    final msg = message ?? _messages.decimal;
    _addValidator('decimal', (v) => v % 1 != 0 ? null : msg);
    return this;
  }

  VDouble integer({String? message}) {
    final msg = message ?? _messages.integer;
    _addValidator('integer', (v) => v % 1 == 0 ? null : msg);
    return this;
  }

  VArray<double> array() => VArray<double>(this);
}
