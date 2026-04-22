import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

/// Validates that a boolean value is `true`.
class IsTrueValidator extends Validator<bool> {
  /// Creates an [IsTrueValidator].
  const IsTrueValidator();

  @override
  String get code => VBoolCode.isTrue;

  @override
  Map<String, dynamic>? validate(bool value) => value == true ? null : {};
}
