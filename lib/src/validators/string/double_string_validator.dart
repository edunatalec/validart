import 'package:validart/src/validators/validator.dart';

/// A validator that checks whether a given string represents a valid double value.
///
/// The `DoubleStringValidator` ensures that the input string can be parsed as a `double`.
///
/// ### Example
/// ```dart
/// final validator = DoubleStringValidator(message: 'Must be a valid double');
///
/// print(validator.validate('123.45')); // null (valid)
/// print(validator.validate('-0.99')); // null (valid)
/// print(validator.validate('abc')); // 'Must be a valid double' (invalid)
/// print(validator.validate('123,45')); // 'Must be a valid double' (invalid)
/// ```
///
/// ## Parameters:
/// - [message]: The error message if validation fails.
///
/// ## Behavior:
/// - If the string can be successfully parsed as a `double`, validation passes.
/// - If the input value is `null` or cannot be converted to a `double`, validation fails.
class DoubleStringValidator extends ValidatorWithMessage<String> {
  /// Creates a `DoubleStringValidator` with the given [message].
  DoubleStringValidator({required super.message});

  @override
  String? validate(covariant String value) {
    return double.tryParse(value) != null ? null : message;
  }
}
