import 'package:validart/src/enums/case_sensitivity.dart';
import 'package:validart/src/validators/validator.dart';

/// A validator that checks whether a given string is exactly equal to a specified value.
///
/// The `EqualsValidator` ensures that the input string matches the expected value,
/// with an optional case sensitivity setting.
///
/// ## Example usage:
/// ```dart
/// final validator = EqualsValidator(
///   'password123',
///   message: 'Value must be exactly "password123"',
/// );
///
/// print(validator.validate('password123')); // null (valid)
/// print(validator.validate('Password123')); // 'Value must be exactly "password123"' (invalid)
///
/// final caseInsensitiveValidator = EqualsValidator(
///   'password123',
///   message: 'Value must be exactly "password123"',
///   caseSensitivity: CaseSensitivity.insensitive,
/// );
///
/// print(caseInsensitiveValidator.validate('PASSWORD123')); // null (valid)
/// ```
///
/// ## Parameters:
/// - [expectedValue]: The exact string value that the input should match.
/// - [message]: The error message returned if validation fails.
/// - [caseSensitivity]: Determines whether validation should be case-sensitive.
///   Defaults to `CaseSensitivity.sensitive`.
class EqualsValidator extends Validator<String> {
  /// The exact string value that the input should match.
  final String expectedValue;

  /// Determines whether the validation should be case-sensitive or not.
  ///
  /// Defaults to `CaseSensitivity.sensitive`.
  final CaseSensitivity caseSensitivity;

  /// Creates an `EqualsValidator` with the given [expectedValue], [message], and [caseSensitivity].
  EqualsValidator(
    this.expectedValue, {
    required super.message,
    this.caseSensitivity = CaseSensitivity.sensitive,
  });

  /// Validates whether the given [value] is equal to [expectedValue].
  ///
  /// - If [caseSensitivity] is `CaseSensitivity.insensitive`, both the input
  ///   and the expected value are converted to lowercase before comparison.
  /// - If the value is `null`, the validation fails.
  ///
  /// Returns `null` if valid, otherwise returns the error message.
  @override
  String? validate(String? value) {
    if (value == null) return message;

    final bool isEqual =
        caseSensitivity == CaseSensitivity.insensitive
            ? value.toLowerCase() == expectedValue.toLowerCase()
            : value == expectedValue;

    return isEqual ? null : message;
  }
}
