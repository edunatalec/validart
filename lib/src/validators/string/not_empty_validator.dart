import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

/// Validates that a string is not empty.
class NotEmptyValidator extends Validator<String> {
  /// Creates a [NotEmptyValidator].
  const NotEmptyValidator();

  @override
  String get code => VStringCode.notEmpty;

  @override
  Map<String, dynamic>? validate(String value) => value.isNotEmpty ? null : {};
}
