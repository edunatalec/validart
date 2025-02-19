import 'package:validart/src/validators/validator.dart';

/// A validator that checks if a boolean value is `false`.
///
/// The `IsFalseValidator` ensures that a given boolean value is explicitly `false`.
/// If the value is `false`, the validation passes (`null` is returned).
/// Otherwise, it returns the provided error [message].
///
/// Example usage:
/// ```dart
/// final validator = IsFalseValidator(message: 'The value must be false');
///
/// print(validator.validate(false)); // null (valid)
/// print(validator.validate(true));  // 'The value must be false' (invalid)
/// print(validator.validate(null));  // 'The value must be false' (invalid)
/// ```
class IsFalseValidator extends ValidatorWithMessage<bool> {
  /// Creates an `IsFalseValidator` with a required error message.
  IsFalseValidator({required super.message});

  @override
  String? validate(value) {
    if (value == false) return null;

    return message;
  }
}
