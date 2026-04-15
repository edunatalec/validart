import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

/// Validates that a boolean value is `false`.
class IsFalseValidator extends Validator<bool> {
  /// Creates an [IsFalseValidator].
  const IsFalseValidator();

  @override
  String get code => VCode.isFalse;

  @override
  Map<String, dynamic>? validate(bool value) => value == false ? null : {};
}
