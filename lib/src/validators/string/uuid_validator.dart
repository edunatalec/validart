import '../../v_code.dart';
import '../validator.dart';

/// Supported UUID versions for filtering validation.
///
/// Covers RFC 4122 (`v1`–`v5`) and RFC 9562 drafts (`v6`–`v8`).
///
/// ```dart
/// V.string().uuid();                                // any version
/// V.string().uuid(version: UuidVersion.v4);         // random only
/// V.string().uuid(version: UuidVersion.v7);         // timestamp-sorted only
/// ```
enum UuidVersion {
  /// Timestamp + MAC address (RFC 4122).
  v1,

  /// DCE Security (RFC 4122).
  v2,

  /// MD5 hash of namespace + name (RFC 4122).
  v3,

  /// Random (RFC 4122) — the most common variant.
  v4,

  /// SHA-1 hash of namespace + name (RFC 4122).
  v5,

  /// Reordered v1 for lexical sortability (RFC 9562).
  v6,

  /// Unix-ms timestamp + random — sortable (RFC 9562).
  v7,

  /// Custom layout (RFC 9562).
  v8,
}

extension _UuidVersionDigit on UuidVersion {
  String get digit => (index + 1).toString();
}

/// Validates that a string is a valid UUID.
///
/// Accepts versions 1 through 8 (RFC 4122 and RFC 9562) by default. Pass
/// [version] to restrict to a specific version.
class UuidValidator extends Validator<String> {
  /// Creates a [UuidValidator].
  const UuidValidator({this.version});

  /// Optional [UuidVersion] filter. When `null`, any supported version is
  /// accepted.
  final UuidVersion? version;

  @override
  String get code => VStringCode.uuid;

  @override
  Map<String, dynamic>? validate(String value) {
    final versionChar = version?.digit ?? '1-8';

    final regex = RegExp(
      '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[$versionChar]'
      r'[0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
    );

    return regex.hasMatch(value) ? null : {'version': version?.name};
  }
}
