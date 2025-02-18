import 'package:validart/src/validators/validator.dart';

/// A validator that ensures a string meets strong password requirements.
///
/// The `PasswordValidator` enforces a set of password complexity rules,
/// ensuring that the input is sufficiently secure.
///
/// ## Validation Rules:
/// - ✅ At least **8** characters long
/// - ❌ No more than **20** characters
/// - ✅ At least **one uppercase letter** (`A-Z`)
/// - ✅ At least **one lowercase letter** (`a-z`)
/// - ✅ At least **one digit** (`0-9`)
/// - ✅ At least **one special character** (`!@#\$%^&*(),.?":{}|<>` etc.)
/// - ❌ **No spaces allowed**
///
/// ## Example usage:
/// ```dart
/// final validator = PasswordValidator(message: 'A senha não atende aos critérios de segurança');
///
/// print(validator.validate('Str0ngP@ss')); // null (valid)
/// print(validator.validate('weakpass')); // 'A senha não atende aos critérios de segurança' (invalid)
/// print(validator.validate('12345678')); // 'A senha não atende aos critérios de segurança' (invalid)
/// ```
///
/// ## Parameters:
/// - [message]: Custom error message when validation fails.
class PasswordValidator extends Validator<String> {
  /// Creates a `PasswordValidator` with a custom error message.
  PasswordValidator({required super.message});

  /// Validates whether the given [value] meets the password complexity requirements.
  ///
  /// - If the password satisfies all rules, returns `null` (valid).
  /// - Otherwise, returns the error message.
  @override
  String? validate(covariant String value) {
    final List<bool Function()> conditions = [
      () => value.isEmpty,
      () => value.length < 8,
      () => value.length > 20,
      () => !RegExp(r'[A-Z]').hasMatch(value),
      () => !RegExp(r'[a-z]').hasMatch(value),
      () => !RegExp(r'\d').hasMatch(value),
      () => !RegExp(r'[\W_]').hasMatch(value),
      () => RegExp(r'\s').hasMatch(value) // No spaces allowed
    ];

    final every = conditions.every((condition) => !condition());

    if (every) return null;

    return message;
  }
}
