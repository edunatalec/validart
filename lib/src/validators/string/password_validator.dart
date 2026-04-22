import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

/// Validates that a string meets password strength requirements.
///
/// Default policy: minimum 8 characters, at least one uppercase, one
/// lowercase, one digit, and one special character from
/// `!@#$%^&*(),.?":{}|<>`. The set of accepted special characters can be
/// overridden via [specialChars].
class PasswordValidator extends Validator<String> {
  /// Default special characters (backwards-compatible set).
  static const defaultSpecialChars = r'!@#$%^&*(),.?":{}|<>';

  /// String whose characters are accepted as "special" — e.g.
  /// `r'!@#$%^&*()-_+=<>?'`. Each character is escaped before use.
  final String specialChars;

  /// Creates a [PasswordValidator]. Keeps backwards-compatible default.
  const PasswordValidator({this.specialChars = defaultSpecialChars})
      : assert(specialChars.length > 0,
            'specialChars cannot be empty — use refine() to drop the requirement');

  @override
  String get code => VStringCode.password;

  @override
  Map<String, dynamic>? validate(String value) {
    if (value.length < 8) return {};
    if (!RegExp(r'[A-Z]').hasMatch(value)) return {};
    if (!RegExp(r'[a-z]').hasMatch(value)) return {};
    if (!RegExp(r'[0-9]').hasMatch(value)) return {};

    final escaped = specialChars.split('').map(RegExp.escape).join();

    if (!RegExp('[$escaped]').hasMatch(value)) return {};

    return null;
  }
}
