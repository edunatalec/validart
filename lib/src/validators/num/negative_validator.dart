import 'package:keeper/src/validators/validator.dart';

/// A validator that ensures a given `num` value is negative.
///
/// The `NegativeValidator` checks whether the provided value is strictly less than zero.
/// If the value is valid, the validation passes (`null` is returned).
/// Otherwise, it returns the provided error [message].
///
/// Example usage:
/// ```dart
/// final validator = NegativeValidator(message: 'Value must be negative');
///
/// print(validator.validate(-5));  // null (valid)
/// print(validator.validate(-0.1)); // null (valid)
/// print(validator.validate(0));   // 'Value must be negative' (invalid)
/// print(validator.validate(5));   // 'Value must be negative' (invalid)
/// print(validator.validate(null)); // 'Value must be negative' (invalid)
/// ```
class NegativeValidator<T extends num> extends KValidator<T> {
  /// Creates a `NegativeValidator` that ensures values are negative.
  ///
  /// The [message] will be returned if validation fails.
  NegativeValidator({required super.message});

  /// Validates whether the given [value] is negative.
  ///
  /// Returns `null` if the value is valid (negative), otherwise returns the validation message.
  @override
  String? validate(value) {
    if (value == null || value >= 0) return message;

    return null;
  }
}
