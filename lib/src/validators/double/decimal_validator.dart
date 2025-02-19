import 'package:validart/src/validators/validator.dart';

/// A validator that ensures a given double value is a decimal (non-integer).
///
/// The `DecimalValidator` checks if a given `double` value is not a whole number.
/// If the value has a fractional part, the validation passes (`null` is returned).
/// Otherwise, it returns the provided error [message].
///
/// ### Example
/// ```dart
/// final validator = DecimalValidator(message: 'The number must be a decimal');
///
/// print(validator.validate(3.14)); // null (valid)
/// print(validator.validate(10.5)); // null (valid)
/// print(validator.validate(4.0));  // 'The number must be a decimal' (invalid)
/// print(validator.validate(null)); // 'The number must be a decimal' (invalid)
/// ```
class DecimalValidator extends ValidatorWithMessage<double> {
  /// Creates a `DecimalValidator` with a required error message.
  DecimalValidator({required super.message});

  @override
  String? validate(covariant double value) {
    if (value % 1 == 0) return message;

    return null;
  }
}
