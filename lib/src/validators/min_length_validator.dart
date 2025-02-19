import 'package:validart/src/validators/validator.dart';

/// A validator that ensures a value has a minimum length.
///
/// This validator checks whether the provided value (either a `String` or a `List`)
/// meets the specified minimum length requirement.
///
/// ### Example
/// ```dart
/// final validator = MinLengthValidator<String>(5, message: 'Too short');
///
/// print(validator.validate('Hello')); // null (valid)
/// print(validator.validate('Hi')); // 'Too short' (invalid)
///
/// final listValidator = MinLengthValidator<List<int>>(3, message: 'List is too short');
///
/// print(listValidator.validate([1, 2, 3])); // null (valid)
/// print(listValidator.validate([1])); // 'List is too short' (invalid)
/// ```
///
/// ## Type Parameter:
/// - `T`: The type of the value being validated (must be `String` or `List`).
///
/// ## Constructor:
/// - [minLength]: The minimum allowed length.
/// - [message]: The error message returned if validation fails.
class MinLengthValidator<T> extends ValidatorWithMessage<T> {
  /// The minimum required length for validation to pass.
  final int minLength;

  /// Creates an instance of `MinLengthValidator` with a given minimum length.
  ///
  /// Throws an `ArgumentError` if the value is neither a `String` nor a `List`.
  MinLengthValidator(this.minLength, {required super.message});

  @override
  String? validate(covariant T value) {
    if (!(value is String || value is List)) {
      throw ArgumentError(
        'MinLengthValidator can only be used with String or List.',
      );
    }

    if ((value as dynamic).length < minLength) return message;

    return null;
  }
}
