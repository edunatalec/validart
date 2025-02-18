import 'package:validart/src/validators/validator.dart';

/// A validator that ensures a string does not exceed a maximum length.
///
/// The `MaxLengthValidator` checks if the input string contains at most the specified number
/// of characters. This is useful for validating input fields with character limits, such as
/// usernames, descriptions, or form fields.
///
/// ## Example usage:
/// ```dart
/// final validator = MaxLengthValidator(10, message: 'Must be at most 10 characters long');
///
/// print(validator.validate('Short')); // null (valid)
/// print(validator.validate('This is too long')); // 'Must be at most 10 characters long' (invalid)
/// ```
///
/// ## Parameters:
/// - [maxLength]: The maximum number of characters allowed.
/// - [message]: The error message returned if the validation fails.
///
/// ## Behavior:
/// - If the input value is `null`, validation passes.
/// - If the input length is greater than `maxLength`, validation fails.
/// - If the input length is less than or equal to `maxLength`, validation passes (`null` is returned).
class MaxLengthValidator extends Validator<String> {
  /// The maximum number of characters allowed for validation.
  final int maxLength;

  /// Creates a `MaxLengthValidator` with the given [maxLength] and [message].
  MaxLengthValidator(this.maxLength, {required super.message});

  /// Validates whether the given [value] does not exceed the maximum length.
  ///
  /// - If the value is `null`, validation passes.
  /// - If the value's length is greater than [maxLength], validation fails.
  /// - Otherwise, validation passes.
  ///
  /// Returns `null` if valid, otherwise returns the error message.
  @override
  String? validate(covariant String value) {
    if (value.length > maxLength) return message;

    return null;
  }
}
