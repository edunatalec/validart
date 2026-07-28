import '../../v_code.dart';
import '../validator.dart';

/// Validates that a string is a valid MAC address.
///
/// Accepts the common colon and dash separators
/// (`AA:BB:CC:DD:EE:FF` or `AA-BB-CC-DD-EE-FF`).
class MacValidator extends Validator<String> {
  /// Creates a [MacValidator].
  const MacValidator();

  @override
  String get code => VStringCode.mac;

  @override
  Map<String, dynamic>? validate(String value) {
    final regex = RegExp(r'^([0-9A-Fa-f]{2}([:-])){5}[0-9A-Fa-f]{2}$');

    if (!regex.hasMatch(value)) return {};

    final separator = value.contains(':') ? ':' : '-';
    final consistent = !value.contains(separator == ':' ? '-' : ':');

    return consistent ? null : {};
  }
}
