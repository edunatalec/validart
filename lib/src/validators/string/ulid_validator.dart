import '../../v_code.dart';
import '../validator.dart';

/// Validates that a string is a valid ULID.
///
/// ULIDs are 26 characters in Crockford's Base32 (excludes `I`, `L`, `O`
/// and `U`). The first character must be `0`–`7` because the timestamp
/// segment is capped at 48 bits.
class UlidValidator extends Validator<String> {
  /// Creates a [UlidValidator].
  const UlidValidator();

  @override
  String get code => VStringCode.ulid;

  @override
  Map<String, dynamic>? validate(String value) {
    final regex =
        RegExp(r'^[0-7][0-9A-HJKMNP-TV-Z]{25}$', caseSensitive: false);

    return regex.hasMatch(value) ? null : {};
  }
}
