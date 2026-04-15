import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

/// Validates that a string is a valid JSON Web Token (JWT).
class JwtValidator extends Validator<String> {
  /// Creates a [JwtValidator].
  const JwtValidator();

  @override
  String get code => VCode.jwt;

  @override
  Map<String, dynamic>? validate(String value) {
    final regex = RegExp(r'^[A-Za-z0-9-_]+\.[A-Za-z0-9-_]+\.[A-Za-z0-9-_]+$');
    return regex.hasMatch(value) ? null : {};
  }
}
