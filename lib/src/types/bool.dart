part of 'type.dart';

/// Validates [bool] values.
///
/// ```dart
/// final schema = V.bool().isTrue();
/// schema.parse(true); // true
/// ```
///
/// See also:
///
///  * [V.bool], the factory that creates this schema.
///  * [VBoolCode], the error codes it emits.
class VBool extends VType<bool> {
  /// Creates a [VBool]. Pass [message] to override the default
  /// translation used when the input is `null`.
  VBool({super.message, super.invalidTypeMessage});

  @override
  String get typeName => 'bool';

  @override
  VBool add(
    Validator<bool> validator, {
    String? message,
    List<Object>? path,
    Set<String>? dependsOn,
  }) {
    super.add(validator, message: message, path: path, dependsOn: dependsOn);
    return this;
  }

  @override
  VBool nullable() {
    super.nullable();
    return this;
  }

  @override
  VBool defaultValue(bool value) {
    super.defaultValue(value);
    return this;
  }

  @override
  VBool preprocess(Object? Function(Object? value) fn) {
    super.preprocess(fn);
    return this;
  }

  @override
  VBool refine(
    bool Function(bool value) check, {
    String? message,
    String? code,
    Set<String>? dependsOn,
  }) {
    super.refine(check, message: message, code: code, dependsOn: dependsOn);
    return this;
  }

  @override
  VBool preprocessAsync(Future<Object?> Function(Object? value) fn) {
    super.preprocessAsync(fn);
    return this;
  }

  @override
  VBool refineAsync(
    Future<bool> Function(bool value) check, {
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

  /// Validates that the value is `true`.
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.bool().isTrue().validate(true);  // true
  /// V.bool().isTrue().validate(false); // false
  /// ```
  VBool isTrue({String? message}) {
    return add(const IsTrueValidator(), message: message);
  }

  /// Validates that the value is `false`.
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.bool().isFalse().validate(false); // true
  /// V.bool().isFalse().validate(true);  // false
  /// ```
  VBool isFalse({String? message}) {
    return add(const IsFalseValidator(), message: message);
  }

  /// Creates a [VArray] schema that validates a `List<bool>`.
  ///
  /// ```dart
  /// V.bool().array().parse([true, false]);
  /// ```
  VArray<bool> array() => VArray<bool>(this);
}
