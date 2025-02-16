import 'package:keeper/src/validators/validator.dart';

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
class IntegerValidator extends KValidator<double> {
  /// Creates an `IntegerValidator` with a required error message.
  IntegerValidator({required super.message});

  /// Validates whether the given [value] is an integer (has no decimal part).
  ///
  /// Returns `null` if the value is an integer, otherwise returns the validation message.
  @override
  String? validate(value) {
    if (value == null || value % 1 != 0) return message;

    return null;
  }
}
