import 'package:validart/src/validators/validator.dart';

/// A validator that ensures a given `num` value does not exceed a specified maximum limit.
///
/// The `MaxValidator` checks if the provided value is less than or equal to [max].
/// If the value is within the allowed range, validation passes (`null` is returned).
/// Otherwise, it returns the provided error [message].
///
/// Example usage:
/// ```dart
/// final validator = MaxValidator(100, message: 'Value must be at most 100');
///
/// print(validator.validate(50));  // null (valid)
/// print(validator.validate(100)); // null (valid)
/// print(validator.validate(101)); // 'Value must be at most 100' (invalid)
/// print(validator.validate(null)); // 'Value must be at most 100' (invalid)
/// ```
class MaxValidator<T extends num> extends Validator<T> {
  /// The maximum allowed value.
  final T max;

  /// Creates a `MaxValidator` with a maximum [max] value and an error [message].
  MaxValidator(this.max, {required super.message});

  /// Validates whether the given [value] is less than or equal to [max].
  ///
  /// Returns `null` if the value is within the allowed range, otherwise returns the validation message.
  @override
  String? validate(covariant T value) {
    if (value > max) return message;

    return null;
  }
}
