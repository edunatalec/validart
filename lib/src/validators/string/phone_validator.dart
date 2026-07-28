import '../../v_code.dart';
import '../validator.dart';
import 'phone_pattern.dart';

/// Validates that a string is a valid phone number.
///
/// Delegates to one or more [PhonePattern]s. Defaults to a single
/// [E164PhonePattern] (matches the E.164 international format). Pass a
/// list of patterns to accept phone numbers from multiple countries
/// without building a [VString] union:
///
/// ```dart
/// V.string().phone(patterns: [
///   const BrPhonePattern(),
///   const UsPhonePattern(),
/// ]);
/// ```
///
/// Validation succeeds when **any** pattern accepts the value. On
/// failure, the emitted error code is the single pattern's [code] when
/// only one pattern is configured, or [VStringCode.phone] when multiple
/// patterns are configured.
class PhoneValidator extends Validator<String> {
  /// Creates a [PhoneValidator]. The [patterns] list must be non-empty.
  PhoneValidator({required this.patterns})
      : assert(patterns.isNotEmpty, 'patterns must not be empty');

  /// The phone patterns accepted by this validator. Validation passes
  /// when at least one of these patterns accepts the input.
  final List<PhonePattern> patterns;

  @override
  String get code =>
      patterns.length == 1 ? patterns.first.code : VStringCode.phone;

  @override
  Map<String, dynamic>? validate(String value) {
    for (final pattern in patterns) {
      if (pattern.validate(value) == null) return null;
    }

    return {};
  }
}
