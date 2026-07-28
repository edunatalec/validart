import '../../v_code.dart';
import '../validator.dart';

/// Validates that a boolean value is `false`.
class IsFalseValidator extends Validator<bool> {
  /// Creates an [IsFalseValidator].
  const IsFalseValidator();

  @override
  String get code => VBoolCode.isFalse;

  @override
  Map<String, dynamic>? validate(bool value) => value == false ? null : {};
}
