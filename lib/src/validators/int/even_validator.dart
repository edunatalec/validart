import 'package:keeper/src/validators/validator.dart';

/// A validator that ensures a given `int` value is even.
///
/// The `EvenValidator` checks if the provided value is an even number (i.e., divisible by 2 without a remainder).
/// If the value is even, validation passes (`null` is returned). Otherwise, it returns the provided error [message].
///
/// Example usage:
/// ```dart
/// final validator = EvenValidator(message: 'The number must be even');
///
/// print(validator.validate(10)); // null (valid)
/// print(validator.validate(-4)); // null (valid)
/// print(validator.validate(3)); // 'The number must be even' (invalid)
/// print(validator.validate(null)); // 'The number must be even' (invalid)
/// ```
class EvenValidator extends KValidator<int> {
  /// Creates an `EvenValidator` with a required error message.
  EvenValidator({required super.message});

  /// Validates whether the given [value] is an even number.
  ///
  /// Returns `null` if the value is even, otherwise returns the validation message.
  @override
  String? validate(int? value) {
    if (value == null || value % 2 != 0) return message;

    return null;
  }
}
