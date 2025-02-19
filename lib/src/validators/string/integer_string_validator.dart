import 'package:validart/src/validators/validator.dart';

/// A validator that checks whether a given string represents a valid integer value.
///
/// The `IntegerStringValidator` ensures that the input string can be parsed as an `int`.
///
/// ### Example
/// ```dart
/// final validator = IntegerStringValidator(message: 'Must be a valid integer');
///
/// print(validator.validate('123')); // null (valid)
/// print(validator.validate('-99')); // null (valid)
/// print(validator.validate('3.14')); // 'Must be a valid integer' (invalid)
/// print(validator.validate('abc')); // 'Must be a valid integer' (invalid)
/// ```
///
/// ## Parameters:
/// - [message]: The error message if validation fails.
///
/// ## Behavior:
/// - If the string can be successfully parsed as an `int`, validation passes.
/// - If the input value is `null` or cannot be converted to an `int`, validation fails.
class IntegerStringValidator extends ValidatorWithMessage<String> {
  /// Creates an `IntegerStringValidator` with the given [message].
  IntegerStringValidator({required super.message});

  @override
  String? validate(covariant String value) {
    return int.tryParse(value) != null ? null : message;
  }
}
