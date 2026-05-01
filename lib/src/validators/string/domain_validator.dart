import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/string/url_validator.dart';
import 'package:validart/src/validators/validator.dart';

/// Validates that a string is a bare host: domain labels (with TLD ≥ 2
/// alphabetic chars) or `localhost`, optionally with a `:port`. Path,
/// query, and fragment are rejected. Scheme is also rejected — for a
/// scheme-prefixed URL use [UrlValidator].
///
/// Reuses the host regex of [UrlValidator] (in scheme-optional /
/// host-only mode), with an extra early-return that rejects any input
/// containing `://`.
class DomainValidator extends Validator<String> {
  /// Creates a [DomainValidator].
  const DomainValidator();

  @override
  String get code => VStringCode.domain;

  @override
  Map<String, dynamic>? validate(String value) {
    if (value.contains('://')) return {};

    return const UrlValidator(schemes: {}, hostOnly: true).validate(value);
  }
}
