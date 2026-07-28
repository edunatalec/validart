import '../../v_code.dart';
import '../validator.dart';

/// Validates that a string is not empty.
class NotEmptyValidator extends Validator<String> {
  /// Creates a [NotEmptyValidator].
  const NotEmptyValidator();

  @override
  String get code => VStringCode.notEmpty;

  @override
  Map<String, dynamic>? validate(String value) => value.isNotEmpty ? null : {};
}
