import '../../v_code.dart';
import '../validator.dart';

/// Validates that a string contains only alphanumeric characters.
class AlphanumericValidator extends Validator<String> {
  /// Creates an [AlphanumericValidator].
  const AlphanumericValidator();

  @override
  String get code => VStringCode.alphanumeric;

  @override
  Map<String, dynamic>? validate(String value) {
    final regex = RegExp(r'^[a-zA-Z0-9]+$');
    return regex.hasMatch(value) ? null : {};
  }
}
