import 'package:validart/src/validators/validator.dart';

/// A validator that ensures a given `double` value is an integer.
///
/// The `IntegerValidator` checks if the provided value is a whole number (i.e., it has no decimal part).
/// If the value is an integer, validation passes (`null` is returned). Otherwise, it returns the provided error [message].
///
/// Example usage:
/// ```dart
/// final validator = IntegerValidator(message: 'The number must be an integer');
///
/// print(validator.validate(10.0)); // null (valid)
/// print(validator.validate(-5.0)); // null (valid)
/// print(validator.validate(3.14)); // 'The number must be an integer' (invalid)
/// print(validator.validate(null)); // 'The number must be an integer' (invalid)
/// ```
class IntegerValidator extends ValidatorWithMessage<double> {
  /// Creates an `IntegerValidator` with a required error message.
  IntegerValidator({required super.message});

  @override
  String? validate(covariant double value) {
    if (value % 1 != 0) return message;

    return null;
  }
}
