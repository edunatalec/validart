import 'package:validart/src/validators/validator.dart';

/// A validator that ensures a string or list does not exceed a specified maximum length.
///
/// This validator checks whether the provided value has a length greater than the
/// specified `maxLength`. If it does, a validation error message is returned.
///
/// ### Example
/// ```dart
/// final validator = MaxLengthValidator<String>(10, message: 'Too long');
///
/// print(validator.validate('Short')); // null (valid)
/// print(validator.validate('This is too long')); // 'Too long' (invalid)
/// ```
///
/// ## Supported Types:
/// - `String`
/// - `List<T>`
///
/// ## Parameters:
/// - [maxLength] The maximum allowed length.
/// - [message] *(required)* The error message returned when validation fails.
///
/// ## Throws:
/// - `ArgumentError` if the value is not a `String` or `List<T>`.
class MaxLengthValidator<T> extends ValidatorWithMessage<T> {
  /// The maximum allowed length for the value.
  final int maxLength;

  /// Creates a `MaxLengthValidator` instance with a defined max length.
  ///
  /// - [maxLength]: The maximum number of characters (for strings) or items (for lists).
  /// - [message]: The error message returned when validation fails.
  MaxLengthValidator(this.maxLength, {required super.message});

  @override
  String? validate(covariant T value) {
    if (!(value is String || value is List)) {
      throw ArgumentError(
        'MaxLengthValidator only supports String and List types.',
      );
    }

    if ((value as dynamic).length > maxLength) return message;

    return null;
  }
}
