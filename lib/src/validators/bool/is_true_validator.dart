import 'package:keeper/src/validators/validator.dart';

/// A validator that checks if a boolean value is `true`.
///
/// The `IsTrueValidator` ensures that a given boolean value is explicitly `true`.
/// If the value is `true`, the validation passes (`null` is returned).
/// Otherwise, it returns the provided error [message].
///
/// Example usage:
/// ```dart
/// final validator = IsTrueValidator(message: 'The value must be true');
///
/// print(validator.validate(true));  // null (valid)
/// print(validator.validate(false)); // 'The value must be true' (invalid)
/// print(validator.validate(null));  // 'The value must be true' (invalid)
/// ```
class IsTrueValidator extends KValidator<bool> {
  /// Creates an `IsTrueValidator` with a required error message.
  IsTrueValidator({required super.message});

  /// Validates whether the given [value] is `true`.
  ///
  /// Returns `null` if the value is `true`, otherwise returns the validation message.
  @override
  String? validate(value) {
    if (value == true) return null;

    return message;
  }
}
