import 'package:validart/src/validators/validator.dart';

/// A validator that ensures a given `num` value meets a specified minimum limit.
///
/// The `MinValidator` checks if the provided value is greater than or equal to [min].
/// If the value is within the allowed range, validation passes (`null` is returned).
/// Otherwise, it returns the provided error [message].
///
/// Example usage:
/// ```dart
/// final validator = MinValidator(10, message: 'Value must be at least 10');
///
/// print(validator.validate(15));  // null (valid)
/// print(validator.validate(10));  // null (valid)
/// print(validator.validate(9));   // 'Value must be at least 10' (invalid)
/// print(validator.validate(null)); // 'Value must be at least 10' (invalid)
/// ```
class MinValidator<T extends num> extends ValidatorWithMessage<T> {
  /// The minimum allowed value.
  final T min;

  /// Creates a `MinValidator` with a minimum [min] value and an error [message].
  MinValidator(this.min, {required super.message});

  @override
  String? validate(covariant T value) {
    if (value < min) return message;

    return null;
  }
}
