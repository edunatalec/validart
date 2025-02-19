import 'package:validart/src/validators/validator.dart';

/// A validator that ensures a given `int` value is odd.
///
/// The `OddValidator` checks if the provided value is an odd number (i.e., not divisible by 2 without a remainder).
/// If the value is odd, validation passes (`null` is returned). Otherwise, it returns the provided error [message].
///
/// ### Example
/// ```dart
/// final validator = OddValidator(message: 'The number must be odd');
///
/// print(validator.validate(11)); // null (valid)
/// print(validator.validate(-5)); // null (valid)
/// print(validator.validate(8)); // 'The number must be odd' (invalid)
/// print(validator.validate(null)); // 'The number must be odd' (invalid)
/// ```
class OddValidator extends ValidatorWithMessage<int> {
  /// Creates an `OddValidator` with a required error message.
  OddValidator({required super.message});

  @override
  String? validate(covariant int value) {
    if (value % 2 == 0) return message;

    return null;
  }
}
