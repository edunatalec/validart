import 'package:validart/src/validators/validator.dart';

/// A validator that checks whether a string meets a minimum length requirement.
///
/// The `MinLengthValidator` ensures that the input string has at least the specified number
/// of characters. This is useful for validating user input fields such as passwords,
/// usernames, or any other text input that requires a minimum length.
///
/// ## Example usage:
/// ```dart
/// final validator = MinLengthValidator(5, message: 'Must be at least 5 characters long');
///
/// print(validator.validate('Hello')); // null (valid)
/// print(validator.validate('Hi')); // 'Must be at least 5 characters long' (invalid)
/// ```
///
/// ## Parameters:
/// - [minLength]: The minimum number of characters required.
/// - [message]: The error message returned if the validation fails.
///
/// ## Behavior:
/// - If the input value is `null`, validation fails.
/// - If the input length is less than `minLength`, validation fails.
/// - If the input length meets or exceeds `minLength`, validation passes (`null` is returned).
class MinLengthValidator extends Validator<String> {
  /// The minimum number of characters required for validation.
  final int minLength;

  /// Creates a `MinLengthValidator` with the given [minLength] and [message].
  MinLengthValidator(this.minLength, {required super.message});

  /// Validates whether the given [value] meets the minimum length requirement.
  ///
  /// - If the value is `null`, validation fails.
  /// - If the value's length is less than [minLength], validation fails.
  /// - Otherwise, validation passes.
  ///
  /// Returns `null` if valid, otherwise returns the error message.
  @override
  String? validate(covariant String value) {
    if (value.length < minLength) return message;

    return null;
  }
}
