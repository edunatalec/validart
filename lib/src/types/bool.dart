part of 'type.dart';

/// Validates [bool] values.
///
/// ```dart
/// final schema = V.bool().isTrue();
/// schema.parse(true); // true
/// ```
class VBool extends VType<bool> {
  /// Validates that the value is `true`.
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.bool().isTrue().validate(true);  // true
  /// V.bool().isTrue().validate(false); // false
  /// ```
  VBool isTrue({String? message}) {
    add(const IsTrueValidator(), message: message);
    return this;
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
    add(const IsFalseValidator(), message: message);
    return this;
  }

  /// Creates a [VArray] schema that validates a `List<bool>`.
  ///
  /// ```dart
  /// V.bool().array().parse([true, false]);
  /// ```
  VArray<bool> array() => VArray<bool>(this);
}
