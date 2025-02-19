import 'package:validart/src/enums/case_sensitivity.dart';
import 'package:validart/src/validators/validator.dart';

/// A validator that checks whether a given string contains a specific substring.
///
/// The `ContainsValidator` ensures that the provided string includes the expected
/// substring, with an option to make the validation case-sensitive or insensitive.
///
/// ### Example
///
/// ```dart
/// final validator = ContainsValidator('dart', message: 'Must contain "dart"');
///
/// print(validator.validate('I love Dart!'));  // null (valid)
/// print(validator.validate('I love Flutter')); // 'Must contain "dart"' (invalid)
///
/// final caseInsensitiveValidator = ContainsValidator(
///   'dart',
///   message: 'Must contain "dart"',
///   caseSensitivity: CaseSensitivity.insensitive,
/// );
///
/// print(caseInsensitiveValidator.validate('I LOVE DART!')); // null (valid)
/// ```
class ContainsValidator extends ValidatorWithMessage<String> {
  /// The substring that should be present in the validated value.
  final String data;

  /// Defines whether the validation should be case-sensitive.
  ///
  /// Defaults to `CaseSensitivity.sensitive`, meaning that "Dart" and "dart"
  /// are considered different.
  final CaseSensitivity caseSensitivity;

  /// Creates a `ContainsValidator` instance with the given [data], [message], and [caseSensitivity].
  ///
  /// By default, the validation is case-sensitive.
  ContainsValidator(
    this.data, {
    required super.message,
    this.caseSensitivity = CaseSensitivity.sensitive,
  });

  @override
  String? validate(covariant String value) {
    final bool contains = caseSensitivity == CaseSensitivity.insensitive
        ? value.toLowerCase().contains(data.toLowerCase())
        : value.contains(data);

    return contains ? null : message;
  }
}
