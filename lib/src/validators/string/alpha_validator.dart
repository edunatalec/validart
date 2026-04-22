import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

/// Validates that a string contains only alphabetic characters.
class AlphaValidator extends Validator<String> {
  /// Creates an [AlphaValidator].
  const AlphaValidator();

  @override
  String get code => VStringCode.alpha;

  @override
  Map<String, dynamic>? validate(String value) {
    final regex = RegExp(r'^[a-zA-Z]+$');
    return regex.hasMatch(value) ? null : {};
  }
}
