/// An abstract base class for defining validation logic.
///
/// This class serves as the foundation for all validators.
/// It provides a `validate` method that must be implemented by subclasses.
///
/// ### Example
/// ```dart
/// class CustomValidator extends Validator<String> {
///   @override
///   String? validate(String? value) {
///     return (value != null && value.length >= 5) ? null : 'Value is too short';
///   }
/// }
///
/// final validator = CustomValidator();
/// print(validator.validate('Hello')); // null (valid)
/// print(validator.validate('Hi')); // 'Value is too short' (invalid)
/// ```
///
/// ## Type Parameter:
/// - `T`: The type of the value to be validated.
abstract class Validator<T> {
  /// Validates the provided [value].
  ///
  /// Returns `null` if the value is valid; otherwise, returns a validation error message.
  String? validate(T? value);
}

/// An abstract base class for validators that include a predefined error message.
///
/// This class extends `Validator<T>` by requiring a validation message,
/// which is automatically included when validation fails.
///
/// ### Example
/// ```dart
/// class MinLengthValidator extends ValidatorWithMessage<String> {
///   final int minLength;
///
///   MinLengthValidator(this.minLength, {required super.message});
///
///   @override
///   String? validate(String? value) {
///     return (value != null && value.length >= minLength) ? null : message;
///   }
/// }
///
/// final validator = MinLengthValidator(5, message: 'Too short');
/// print(validator.validate('Hello')); // null (valid)
/// print(validator.validate('Hi')); // 'Too short' (invalid)
/// ```
///
/// ## Type Parameter:
/// - `T`: The type of the value to be validated.
abstract class ValidatorWithMessage<T> extends Validator<T> {
  /// The error message to be returned when validation fails.
  final String message;

  /// Creates a validator that requires an error message.
  ///
  /// - [message]: The error message returned when validation fails.
  ValidatorWithMessage({required this.message});
}
