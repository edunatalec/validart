import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/string/postal_code_pattern.dart';
import 'package:validart/src/validators/validator.dart';

/// Validates that a string is a valid postal code for the given pattern.
class PostalCodeValidator extends Validator<String> {
  /// The postal-code pattern to match against.
  final PostalCodePattern pattern;

  /// Creates a [PostalCodeValidator].
  const PostalCodeValidator({required this.pattern});

  @override
  String get code => VCode.postalCode;

  @override
  Map<String, dynamic>? validate(String value) =>
      pattern.matches(value) ? null : {'name': pattern.name};
}
