import '../../v_code.dart';
import '../validator.dart';

/// Validates that a string is valid Base64 (RFC 4648).
class Base64Validator extends Validator<String> {
  /// Creates a [Base64Validator].
  const Base64Validator();

  @override
  String get code => VStringCode.base64;

  @override
  Map<String, dynamic>? validate(String value) {
    if (value.isEmpty) return {};

    if (value.length % 4 != 0) return {};

    final regex = RegExp(r'^[A-Za-z0-9+/]+={0,2}$');

    return regex.hasMatch(value) ? null : {};
  }
}
