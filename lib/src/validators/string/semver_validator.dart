import '../../v_code.dart';
import '../validator.dart';

/// Validates that a string is a valid Semantic Version (SemVer 2.0).
///
/// Accepts `MAJOR.MINOR.PATCH` with optional pre-release and build
/// metadata (`1.0.0-alpha.1+build.123`).
class SemverValidator extends Validator<String> {
  /// Creates a [SemverValidator].
  const SemverValidator();

  @override
  String get code => VStringCode.semver;

  @override
  Map<String, dynamic>? validate(String value) {
    final regex = RegExp(
      r'^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)'
      r'(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)'
      r'(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?'
      r'(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$',
    );

    return regex.hasMatch(value) ? null : {};
  }
}
