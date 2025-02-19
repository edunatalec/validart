import 'package:validart/src/validators/validator.dart';

/// A validator that ensures a given string is a valid Brazilian postal code (CEP).
///
/// The `CEPValidator` checks whether the provided value follows the Brazilian CEP format,
/// which consists of exactly 8 digits (without special characters) and is not a repeated sequence of numbers.
///
/// Example usage:
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
class CEPValidator extends ValidatorWithMessage<String> {
  /// Creates a `CEPValidator` with a custom [message] for validation failures.
  CEPValidator({required super.message});

  @override
  String? validate(covariant String value) {
    final cep = value.replaceAll(RegExp(r'[^\d]'), '');

    if (!RegExp(r'^\d{8}$').hasMatch(cep)) return message;

    if (RegExp(r'^(.)\1*$').hasMatch(cep)) return message;

    return null;
  }
}
