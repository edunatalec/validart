import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

/// Validates that a string is a valid UUID (versions 1-5).
class UuidValidator extends Validator<String> {
  /// Creates a [UuidValidator].
  const UuidValidator();

  @override
  String get code => VCode.invalidUuid;

  @override
  Map<String, dynamic>? validate(String value) {
    final regex = RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$');
    return regex.hasMatch(value) ? null : {};
  }
}
