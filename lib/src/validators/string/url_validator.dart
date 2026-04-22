import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

/// Validates that a string is a valid URL for one of the allowed
/// [schemes]. Defaults to `{http, https}` to preserve web-URL behavior;
/// pass a custom set to accept `ftp`, `ws`, `file`, etc.
class UrlValidator extends Validator<String> {
  /// Set of accepted URL schemes (without `://`).
  final Set<String> schemes;

  /// Creates a [UrlValidator]. Defaults to `{http, https}`.
  const UrlValidator({this.schemes = const {'http', 'https'}});

  @override
  String get code => VStringCode.url;

  @override
  Map<String, dynamic>? validate(String value) {
    final alt = schemes.map(RegExp.escape).join('|');
    final regex = RegExp('^(?:$alt)://[^\\s/\$.?#].[^\\s]*\$');

    return regex.hasMatch(value) ? null : {};
  }
}
