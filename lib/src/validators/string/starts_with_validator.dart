import 'package:validart/src/enums/case_sensitivity.dart';
import 'package:validart/src/validators/validator.dart';

/// A validator that checks whether a given string starts with a specific prefix.
///
/// The `StartsWithValidator` ensures that the input string begins with the expected prefix,
/// with support for case-sensitive and case-insensitive validation.
///
/// ### Example
/// ```dart
/// final validator = StartsWithValidator(
///   'Hello',
///   message: 'Must start with "Hello"',
/// );
///
/// print(validator.validate('Hello World')); // null (valid)
/// print(validator.validate('hello world')); // 'Must start with "Hello"' (invalid)
///
/// final caseInsensitiveValidator = StartsWithValidator(
///   'hello',
///   message: 'Must start with "hello"',
///   caseSensitivity: CaseSensitivity.insensitive,
/// );
///
/// print(caseInsensitiveValidator.validate('Hello World')); // null (valid)
/// ```
///
/// ## Parameters:
/// - [prefix]: The required prefix that the string must start with.
/// - [message]: The error message if validation fails.
/// - [caseSensitivity]: Defines whether the validation should be case-sensitive or not (default: `CaseSensitivity.sensitive`).
///
/// ## Behavior:
/// - If `caseSensitivity` is `CaseSensitivity.insensitive`, both the prefix and the input value
///   are converted to lowercase before comparison.
/// - If the input value is `null`, validation fails.
class StartsWithValidator extends ValidatorWithMessage<String> {
  /// The required prefix for validation.
  final String prefix;

  /// Determines whether the validation is case-sensitive or not.
  ///
  /// Defaults to `CaseSensitivity.sensitive`.
  final CaseSensitivity caseSensitivity;

  /// Creates a `StartsWithValidator` with the given [prefix], [message], and [caseSensitivity].
  StartsWithValidator(
    this.prefix, {
    required super.message,
    this.caseSensitivity = CaseSensitivity.sensitive,
  });

  @override
  String? validate(covariant String value) {
    final bool startsWith = caseSensitivity == CaseSensitivity.insensitive
        ? value.toLowerCase().startsWith(prefix.toLowerCase())
        : value.startsWith(prefix);

    return startsWith ? null : message;
  }
}
