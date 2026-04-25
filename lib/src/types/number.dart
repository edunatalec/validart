part of 'type.dart';

/// Abstract base for numeric validation types ([VInt] and [VDouble]).
///
/// ```dart
/// V.int().min(0).max(100).parse(42); // 42
/// ```
abstract class VNumber<T extends num> extends VType<T> {
  /// Creates a [VNumber]. Pass [message] to override the default
  /// translation used when the input is `null`.
  VNumber({super.message});

  @override
  VNumber<T> add(
    Validator<T> validator, {
    String? message,
    List<Object>? path,
    Set<String>? dependsOn,
  }) {
    super.add(validator, message: message, path: path, dependsOn: dependsOn);
    return this;
  }

  /// Validates that the value is at least [value].
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.int().min(5).validate(5);  // true
  /// V.int().min(5).validate(3);  // false
  /// ```
  VNumber<T> min(T value, {String Function(T)? message}) {
    return add(MinValidator<T>(min: value), message: message?.call(value));
  }

  /// Validates that the value is at most [value].
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.int().max(10).validate(10); // true
  /// V.int().max(10).validate(15); // false
  /// ```
  VNumber<T> max(T value, {String Function(T)? message}) {
    return add(MaxValidator<T>(max: value), message: message?.call(value));
  }

  /// Validates that the value is greater than zero.
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.int().positive().validate(1);  // true
  /// V.int().positive().validate(-1); // false
  /// ```
  VNumber<T> positive({String? message}) {
    return add(PositiveValidator<T>(), message: message);
  }

  /// Validates that the value is less than zero.
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.int().negative().validate(-1); // true
  /// V.int().negative().validate(1);  // false
  /// ```
  VNumber<T> negative({String? message}) {
    return add(NegativeValidator<T>(), message: message);
  }

  /// Validates that the value is between [min] and [max] (inclusive).
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.int().between(1, 10).validate(5);  // true
  /// V.int().between(1, 10).validate(15); // false
  /// ```
  VNumber<T> between(T min, T max, {String Function(T, T)? message}) {
    return add(
      BetweenValidator<T>(min: min, max: max),
      message: message?.call(min, max),
    );
  }

  /// Validates that the value is a multiple of [factor].
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.int().multipleOf(3).validate(9); // true
  /// V.int().multipleOf(3).validate(7); // false
  /// ```
  VNumber<T> multipleOf(T factor, {String Function(T)? message}) {
    return add(
      MultipleOfValidator<T>(factor: factor),
      message: message?.call(factor),
    );
  }
}

/// Validates [int] values.
///
/// ```dart
/// final schema = V.int().positive().even();
/// schema.parse(4); // 4
/// ```
class VInt extends VNumber<int> {
  /// Creates a [VInt]. Pass [message] to override the default
  /// translation used when the input is `null`.
  VInt({super.message});

  @override
  String get typeName => 'int';

  @override
  VInt add(
    Validator<int> validator, {
    String? message,
    List<Object>? path,
    Set<String>? dependsOn,
  }) {
    super.add(validator, message: message, path: path, dependsOn: dependsOn);
    return this;
  }

  @override
  VInt nullable() {
    super.nullable();
    return this;
  }

  @override
  VInt defaultValue(int value) {
    super.defaultValue(value);
    return this;
  }

  @override
  VInt preprocess(Object? Function(Object? value) fn) {
    super.preprocess(fn);
    return this;
  }

  @override
  VInt refine(
    bool Function(int value) check, {
    String? message,
    String? code,
    Set<String>? dependsOn,
  }) {
    super.refine(check, message: message, code: code, dependsOn: dependsOn);
    return this;
  }

  @override
  VInt preprocessAsync(Future<Object?> Function(Object? value) fn) {
    super.preprocessAsync(fn);
    return this;
  }

  @override
  VInt refineAsync(
    Future<bool> Function(int value) check, {
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

  @override
  VInt min(int value, {String Function(int)? message}) {
    super.min(value, message: message);
    return this;
  }

  @override
  VInt max(int value, {String Function(int)? message}) {
    super.max(value, message: message);
    return this;
  }

  @override
  VInt positive({String? message}) {
    super.positive(message: message);
    return this;
  }

  @override
  VInt negative({String? message}) {
    super.negative(message: message);
    return this;
  }

  @override
  VInt between(int min, int max, {String Function(int, int)? message}) {
    super.between(min, max, message: message);
    return this;
  }

  @override
  VInt multipleOf(int factor, {String Function(int)? message}) {
    super.multipleOf(factor, message: message);
    return this;
  }

  /// Validates that the value is even.
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.int().even().validate(4); // true
  /// V.int().even().validate(3); // false
  /// ```
  VInt even({String? message}) {
    return add(const EvenValidator(), message: message);
  }

  /// Validates that the value is odd.
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.int().odd().validate(3); // true
  /// V.int().odd().validate(4); // false
  /// ```
  VInt odd({String? message}) {
    return add(const OddValidator(), message: message);
  }

  /// Validates that the value is a prime number.
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.int().prime().validate(7); // true
  /// V.int().prime().validate(4); // false
  /// ```
  VInt prime({String? message}) {
    return add(const PrimeValidator(), message: message);
  }

  /// Creates a [VArray] schema that validates a `List<int>`.
  ///
  /// ```dart
  /// V.int().positive().array().parse([1, 2, 3]);
  /// ```
  VArray<int> array() => VArray<int>(this);
}

/// Validates [double] values.
///
/// ```dart
/// final schema = V.double().positive().finite();
/// schema.parse(3.14); // 3.14
/// ```
class VDouble extends VNumber<double> {
  /// Creates a [VDouble]. Pass [message] to override the default
  /// translation used when the input is `null`.
  VDouble({super.message});

  @override
  String get typeName => 'double';

  @override
  VDouble add(
    Validator<double> validator, {
    String? message,
    List<Object>? path,
    Set<String>? dependsOn,
  }) {
    super.add(validator, message: message, path: path, dependsOn: dependsOn);
    return this;
  }

  @override
  VDouble nullable() {
    super.nullable();
    return this;
  }

  @override
  VDouble defaultValue(double value) {
    super.defaultValue(value);
    return this;
  }

  @override
  VDouble preprocess(Object? Function(Object? value) fn) {
    super.preprocess(fn);
    return this;
  }

  @override
  VDouble refine(
    bool Function(double value) check, {
    String? message,
    String? code,
    Set<String>? dependsOn,
  }) {
    super.refine(check, message: message, code: code, dependsOn: dependsOn);
    return this;
  }

  @override
  VDouble preprocessAsync(Future<Object?> Function(Object? value) fn) {
    super.preprocessAsync(fn);
    return this;
  }

  @override
  VDouble refineAsync(
    Future<bool> Function(double value) check, {
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

  @override
  VDouble min(double value, {String Function(double)? message}) {
    super.min(value, message: message);
    return this;
  }

  @override
  VDouble max(double value, {String Function(double)? message}) {
    super.max(value, message: message);
    return this;
  }

  @override
  VDouble positive({String? message}) {
    super.positive(message: message);
    return this;
  }

  @override
  VDouble negative({String? message}) {
    super.negative(message: message);
    return this;
  }

  @override
  VDouble between(
    double min,
    double max, {
    String Function(double, double)? message,
  }) {
    super.between(min, max, message: message);
    return this;
  }

  @override
  VDouble multipleOf(double factor, {String Function(double)? message}) {
    super.multipleOf(factor, message: message);
    return this;
  }

  /// Validates that the value is finite (not infinity or NaN).
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.double().finite().validate(3.14);             // true
  /// V.double().finite().validate(double.infinity);   // false
  /// ```
  VDouble finite({String? message}) {
    return add(const FiniteValidator(), message: message);
  }

  /// Validates that the value has a fractional part (is not a whole number).
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.double().decimal().validate(3.14); // true
  /// V.double().decimal().validate(3.0);  // false
  /// ```
  VDouble decimal({String? message}) {
    return add(const DecimalValidator(), message: message);
  }

  /// Validates that the value is a whole number (no fractional part).
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.double().integer().validate(3.0);  // true
  /// V.double().integer().validate(3.14); // false
  /// ```
  VDouble integer({String? message}) {
    return add(const IntegerDoubleValidator(), message: message);
  }

  /// Creates a [VArray] schema that validates a `List<double>`.
  ///
  /// ```dart
  /// V.double().positive().array().parse([1.1, 2.2]);
  /// ```
  VArray<double> array() => VArray<double>(this);
}
