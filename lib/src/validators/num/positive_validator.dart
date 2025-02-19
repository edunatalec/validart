import 'package:validart/src/validators/validator.dart';

/// A validator that ensures a given `num` value is positive.
///
/// The `PositiveValidator` checks whether the provided value is strictly greater than zero.
/// If the value is valid, the validation passes (`null` is returned).
/// Otherwise, it returns the provided error [message].
///
/// ### Example
/// ```dart
/// final validator = PositiveValidator(message: 'Value must be positive');
///
/// print(validator.validate(5));    // null (valid)
/// print(validator.validate(0.1));  // null (valid)
/// print(validator.validate(0));    // 'Value must be positive' (invalid)
/// print(validator.validate(-5));   // 'Value must be positive' (invalid)
/// print(validator.validate(null)); // 'Value must be positive' (invalid)
/// ```
class PositiveValidator<T extends num> extends ValidatorWithMessage<T> {
  /// Creates a `PositiveValidator` that ensures values are positive.
  ///
  /// The [message] will be returned if validation fails.
  PositiveValidator({required super.message});

  @override
  String? validate(covariant T value) {
    if (value <= 0) return message;

    return null;
  }
}
