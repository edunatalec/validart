import '../../v_code.dart';
import '../validator.dart';

/// Validates that a string is a valid time in `HH:mm` or `HH:mm:ss` format.
class TimeValidator extends Validator<String> {
  /// Creates a [TimeValidator].
  const TimeValidator();

  @override
  String get code => VStringCode.time;

  @override
  Map<String, dynamic>? validate(String value) {
    final regex = RegExp(r'^([01]\d|2[0-3]):[0-5]\d(:[0-5]\d)?$');
    return regex.hasMatch(value) ? null : {};
  }
}
