/// An abstract class representing a generic validator.
///
/// A `KValidator<T>` is used to validate values of type `T`. Each implementation
/// should provide its own validation logic in the [validate] method.
///
/// Example of implementing a custom validator:
/// ```dart
/// class CustomValidator extends KValidator<String> {
///   CustomValidator({required String message}) : super(message: message);
///
///   @override
///   String? validate(String? value) {
///     if (value == null || value.isEmpty) return message;
///     return null;
///   }
/// }
///
/// final validator = CustomValidator(message: 'Value cannot be empty');
/// print(validator.validate('Hello')); // null (valid)
/// print(validator.validate('')); // 'Value cannot be empty' (invalid)
/// ```
abstract class KValidator<T> {
  /// The error message to be returned when validation fails.
  final String message;

  /// Creates a validator with a required error message.
  KValidator({required this.message});

  /// Validates the given [value]. Returns `null` if valid, otherwise returns
  /// the error message.
  String? validate(T? value);
}
