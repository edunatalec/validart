import 'package:validart/src/validators/string/phone_pattern.dart';
import 'package:validart/src/validators/validator.dart';

/// Validates that a string is a valid phone number.
///
/// Delegates to a [PhonePattern]. Defaults to [E164PhonePattern], which
/// matches the E.164 international format. Plug country-specific patterns
/// by passing them via [pattern] (for instance `BrPhonePattern` from the
/// `validart_br` package).
class PhoneValidator extends Validator<String> {
  /// The phone pattern used to validate the value.
  final PhonePattern pattern;

  /// Creates a [PhoneValidator] with the given [pattern]
  /// (default: [E164PhonePattern]).
  const PhoneValidator({this.pattern = const E164PhonePattern()});

  @override
  String get code => pattern.code;

  @override
  Map<String, dynamic>? validate(String value) => pattern.validate(value);
}
