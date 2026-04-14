part of 'type.dart';

abstract class VNumber<T extends num> extends VType<T> {
  VNumber<T> min(T value, {String Function(T)? message}) {
    add(MinValidator<T>(min: value), message: message?.call(value));
    return this;
  }

  VNumber<T> max(T value, {String Function(T)? message}) {
    add(MaxValidator<T>(max: value), message: message?.call(value));
    return this;
  }

  VNumber<T> positive({String? message}) {
    add(PositiveValidator<T>(), message: message);
    return this;
  }

  VNumber<T> negative({String? message}) {
    add(NegativeValidator<T>(), message: message);
    return this;
  }

  VNumber<T> between(T min, T max, {String Function(T, T)? message}) {
    add(
      BetweenValidator<T>(min: min, max: max),
      message: message?.call(min, max),
    );
    return this;
  }

  VNumber<T> multipleOf(T factor, {String Function(T)? message}) {
    add(MultipleOfValidator<T>(factor: factor), message: message?.call(factor));
    return this;
  }
}

class VInt extends VNumber<int> {
  VInt even({String? message}) {
    add(const EvenValidator(), message: message);
    return this;
  }

  VInt odd({String? message}) {
    add(const OddValidator(), message: message);
    return this;
  }

  VInt prime({String? message}) {
    add(const PrimeValidator(), message: message);
    return this;
  }

  VArray<int> array() => VArray<int>(this);
}

class VDouble extends VNumber<double> {
  VDouble finite({String? message}) {
    add(const FiniteValidator(), message: message);
    return this;
  }

  VDouble decimal({String? message}) {
    add(const DecimalValidator(), message: message);
    return this;
  }

  VDouble integer({String? message}) {
    add(const IntegerDoubleValidator(), message: message);
    return this;
  }

  VArray<double> array() => VArray<double>(this);
}
