import '../../v_code.dart';
import '../validator.dart';

/// Validates that a string is a valid CVV/CVC — 3 or 4 digits.
class CvvValidator extends Validator<String> {
  /// Creates a [CvvValidator].
  const CvvValidator();

  @override
  String get code => VStringCode.cvv;

  @override
  Map<String, dynamic>? validate(String value) {
    final regex = RegExp(r'^\d{3,4}$');

    return regex.hasMatch(value) ? null : {};
  }
}
