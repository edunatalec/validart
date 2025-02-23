import 'package:validart/src/enums/validation_mode.dart';
import 'package:validart/src/extensions/string_extensions.dart';
import 'package:validart/src/extensions/validation_mode_extensions.dart';
import 'package:validart/src/validators/validator.dart';

/// A validator that ensures a given string is a valid Brazilian postal code (CEP).
///
/// The `CEPValidator` checks whether the provided value follows the Brazilian CEP format,
/// which consists of exactly 8 digits (without special characters) and is not a repeated sequence of numbers.
///
/// ### Validation Modes
/// - `ValidationMode.formatted` → Expects the CEP in the **formatted** pattern: `"XXXXX-XXX"` (e.g., `"01001-000"`).
/// - `ValidationMode.unformatted` (default) → Expects only **digits**: `"XXXXXXXX"` (e.g., `"01001000"`).
///
/// ### Example
/// ```dart
/// final validator = CEPValidator(message: 'Invalid CEP');
///
/// print(validator.validate('01001-000'));  // null (valid)
/// print(validator.validate('01001000'));   // null (valid)
/// print(validator.validate('00000-000'));  // 'Invalid CEP' (invalid)
/// print(validator.validate('abcdefgh'));   // 'Invalid CEP' (invalid)
/// print(validator.validate('1234'));       // 'Invalid CEP' (invalid)
/// print(validator.validate(null));         // 'Invalid CEP' (invalid)
/// ```
///
/// ### Behavior
/// - Ensures the CEP format matches the expected pattern.
/// - Removes non-digit characters when `ValidationMode.unformatted` is used.
/// - Rejects values where all characters are the same (e.g., `"00000000"` or `"11111-111"`).
class CEPValidator extends ValidatorWithMessage<String> {
  /// Defines whether the CEP should be validated as **formatted** (`XXXXX-XXX`)
  /// or **unformatted** (`XXXXXXXX`).
  final ValidationMode mode;

  /// Creates a `CEPValidator` with a custom [message] for validation failures.
  ///
  /// By default, it expects an **unformatted** CEP (8 digits).
  ///
  /// ```dart
  /// final validator = CEPValidator(message: 'Invalid CEP');
  ///
  /// print(validator.validate("01001-000")); // null (valid)
  /// print(validator.validate("01001000"));  // null (valid)
  ///
  /// final formattedValidator = CEPValidator(
  ///   message: 'Invalid CEP',
  ///   mode: ValidationMode.formatted,
  /// );
  ///
  /// print(formattedValidator.validate("01001-000")); // null (valid)
  /// print(formattedValidator.validate("01001000"));  // "Invalid CEP" (invalid)
  /// ```
  CEPValidator({
    required super.message,
    this.mode = ValidationMode.unformatted,
  });

  @override
  String? validate(covariant String value) {
    String cep = mode.isUnformatted ? value.onlyDigits : value;

    final regex =
        mode.isFormatted ? RegExp(r'^\d{5}-\d{3}$') : RegExp(r'^\d{8}$');

    if (!regex.hasMatch(cep)) return message;

    if (cep.onlyDigits.isRepeatedCharacters) return message;

    return null;
  }
}
