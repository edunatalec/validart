import 'package:validart/src/validators/validator.dart';

/// A validator that ensures a given `num` value falls within a specified range.
///
/// The `BetweenValidator` checks if the provided value is between the specified [min] and [max] values (inclusive).
/// If the value is within the range, validation passes (`null` is returned). Otherwise, it returns the provided error [message].
///
/// ### Example
/// ```dart
/// final validator = BetweenValidator(10, 20, message: 'Value must be between 10 and 20');
///
/// print(validator.validate(15)); // null (valid)
/// print(validator.validate(10)); // null (valid)
/// print(validator.validate(20)); // null (valid)
/// print(validator.validate(9));  // 'Value must be between 10 and 20' (invalid)
/// print(validator.validate(21)); // 'Value must be between 10 and 20' (invalid)
/// print(validator.validate(null)); // 'Value must be between 10 and 20' (invalid)
/// ```
class BetweenValidator<T extends num> extends ValidatorWithMessage<T> {
  /// The minimum allowed value.
  final T min;

  /// The maximum allowed value.
  final T max;

  /// Creates a `BetweenValidator` with the specified [min] and [max] bounds and an error [message].
  BetweenValidator(this.min, this.max, {required super.message});

  @override
  String? validate(covariant T value) {
    if (value < min || value > max) return message;

    return null;
  }
}
