part of 'type.dart';

abstract class VNumber<T extends num> extends VType<T> {
  VNumberMessages get _messages;

  VNumber<T> min(T value, {String Function(T)? message}) {
    _add(MinValidator(
      min: value,
      message: message?.call(value) ?? _messages.min(value),
    ));
    return this;
  }

  VNumber<T> max(T value, {String Function(T)? message}) {
    _add(MaxValidator(
      max: value,
      message: message?.call(value) ?? _messages.max(value),
    ));
    return this;
  }

  VNumber<T> positive({String? message}) {
    _add(PositiveValidator(message: message ?? _messages.positive));
    return this;
  }

  VNumber<T> negative({String? message}) {
    _add(NegativeValidator(message: message ?? _messages.negative));
    return this;
  }

  VNumber<T> between(T min, T max, {String Function(T, T)? message}) {
    _add(BetweenValidator(
      min: min,
      max: max,
      message: message?.call(min, max) ?? _messages.between(min, max),
    ));
    return this;
  }

  VNumber<T> multipleOf(T factor, {String Function(T)? message}) {
    _add(MultipleOfValidator(
      factor: factor,
      message: message?.call(factor) ?? _messages.multipleOf(factor),
    ));
    return this;
  }
}

class VInt extends VNumber<int> {
  @override
  final VNumberMessages _messages;

  VInt({
    VNumberMessages? messages,
    String? requiredMessage,
    String Function(String, String)? invalidTypeMessage,
  }) : _messages = messages ?? const VNumberMessages() {
    if (requiredMessage != null) _requiredMessage = requiredMessage;
    if (invalidTypeMessage != null) _invalidTypeMessage = invalidTypeMessage;
  }

  VInt even({String? message}) {
    _add(EvenValidator(message: message ?? _messages.even));
    return this;
  }

  VInt odd({String? message}) {
    _add(OddValidator(message: message ?? _messages.odd));
    return this;
  }

  VInt prime({String? message}) {
    _add(PrimeValidator(message: message ?? _messages.prime));
    return this;
  }

  VArray<int> array() => VArray<int>(this);
}

class VDouble extends VNumber<double> {
  @override
  final VNumberMessages _messages;

  VDouble({
    VNumberMessages? messages,
    String? requiredMessage,
    String Function(String, String)? invalidTypeMessage,
  }) : _messages = messages ?? const VNumberMessages() {
    if (requiredMessage != null) _requiredMessage = requiredMessage;
    if (invalidTypeMessage != null) _invalidTypeMessage = invalidTypeMessage;
  }

  VDouble finite({String? message}) {
    _add(FiniteValidator(message: message ?? _messages.finite));
    return this;
  }

  VDouble decimal({String? message}) {
    _add(DecimalValidator(message: message ?? _messages.decimal));
    return this;
  }

  VDouble integer({String? message}) {
    _add(IntegerDoubleValidator(message: message ?? _messages.integer));
    return this;
  }

  VArray<double> array() => VArray<double>(this);
}
