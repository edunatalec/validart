import 'package:validart/src/enums/case_sensitivity.dart';
import 'package:validart/src/validators/validator.dart';

/// A validator that checks whether a given string ends with a specific suffix.
///
/// The `EndsWithValidator` ensures that the input string ends with the
/// specified suffix, with an optional case sensitivity setting.
///
/// ### Example
/// ```dart
/// final validator = EndsWithValidator(
///   'dart',
///   message: 'Must end with "dart"',
/// );
///
/// print(validator.validate('hello dart')); // null (valid)
/// print(validator.validate('hello Dart')); // 'Must end with "dart"' (invalid)
///
/// final caseInsensitiveValidator = EndsWithValidator(
///   'dart',
///   message: 'Must end with "dart"',
///   caseSensitivity: CaseSensitivity.insensitive,
/// );
///
/// print(caseInsensitiveValidator.validate('hello Dart')); // null (valid)
/// ```
///
/// ### Parameters
/// - [suffix]: The required suffix that the string should end with.
/// - [message]: The error message returned if validation fails.
/// - [caseSensitivity]: Determines whether validation should be case-sensitive.
///   Defaults to `CaseSensitivity.sensitive`.
class EndsWithValidator extends ValidatorWithMessage<String> {
  /// The required suffix that the string should end with.
  final String suffix;

  /// Determines whether the validation should be case-sensitive or not.
  ///
  /// Defaults to `CaseSensitivity.sensitive`.
  final CaseSensitivity caseSensitivity;

  /// Creates an `EndsWithValidator` with the given [suffix], [message], and [caseSensitivity].
  EndsWithValidator(
    this.suffix, {
    required super.message,
    this.caseSensitivity = CaseSensitivity.sensitive,
  });

  @override
  String? validate(covariant String value) {
    final bool endsWith = caseSensitivity == CaseSensitivity.insensitive
        ? value.toLowerCase().endsWith(suffix.toLowerCase())
        : value.endsWith(suffix);

    return endsWith ? null : message;
  }
}
