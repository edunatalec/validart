import 'package:validart/src/validators/validator.dart';

/// A validator that allows for custom validation logic.
///
/// This validator is useful for defining validation rules that are not covered
/// by built-in validators.
///
/// Example:
/// ```dart
/// final validator = v.string().refine(
///   (value) => value?.contains('@') ?? false,
///   message: 'Must contain "@"',
/// );
///
/// print(validator.validate('email@example.com')); // true
/// print(validator.validate('invalidemail.com')); // false
/// ```
class RefineValidator<T> extends ValidatorWithMessage<T> {
  /// A custom function that determines whether the value is valid.
  ///
  /// If the function returns `true`, the value is considered valid.
  /// If it returns `false`, the validation fails, and the provided error message is used.
  final bool Function(T data) validator;

  /// Creates a [RefineValidator] with a custom validation function.
  ///
  /// The [validator] function should return `true` for valid values and `false` for invalid ones.
  RefineValidator(this.validator, {required super.message});

  @override
  String? validate(covariant T value) {
    return validator(value) ? null : message;
  }
}
