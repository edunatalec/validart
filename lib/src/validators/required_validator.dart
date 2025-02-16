import 'package:validart/src/validators/validator.dart';

/// A validator that ensures a value is provided.
///
/// Example:
/// ```dart
/// final validator = RequiredValidator(message: 'This field is required');
///
/// print(validator.validate('Hello')); // null (valid)
/// print(validator.validate('')); // 'This field is required' (invalid)
/// print(validator.validate(null)); // 'This field is required' (invalid)
/// print(validator.validate({})); // 'This field is required' (invalid)
/// ```
class RequiredValidator<T> extends Validator<T> {
  /// Creates a [RequiredValidator] with a custom error message.
  RequiredValidator({required super.message});

  @override
  String? validate(value) {
    if (value == null) return message;
    if (value is Map && value.isEmpty) return message;
    if (value is String && value.isEmpty) return message;

    return null;
  }
}
