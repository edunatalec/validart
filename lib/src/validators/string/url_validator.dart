import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

/// Validates that a string is a valid URL.
///
/// [schemes] controls the scheme requirement:
/// - `null` (default) — equivalent to `{'http', 'https'}`; one of those
///   schemes is required.
/// - non-empty set — one of those schemes is required.
/// - empty set (`const {}`) — scheme is optional. Any well-formed scheme
///   is accepted when present (`https://google.com`), and a bare host
///   is accepted when absent (`google.com`).
///
/// [hostOnly] (`false` by default) controls the tail:
/// - `false` — accepts a trailing path / query / fragment
///   (`https://example.com/foo?x=1#frag`).
/// - `true` — rejects anything after the host:port. Useful for fields
///   that should only contain a domain (and optionally a port), not a
///   full URL.
///
/// Host shape: standard domain labels separated by dots with a TLD of 2+
/// alphabetic characters, OR the literal `localhost`. An optional `:port`
/// suffix is always allowed.
class UrlValidator extends Validator<String> {
  /// Set of accepted URL schemes (without `://`). Pass `const {}` to
  /// make the scheme optional.
  final Set<String> schemes;

  /// When `true`, rejects any path / query / fragment after the host.
  final bool hostOnly;

  /// Creates a [UrlValidator]. Defaults to `{http, https}` required and
  /// path/query/fragment allowed.
  const UrlValidator({
    this.schemes = const {'http', 'https'},
    this.hostOnly = false,
  });

  @override
  String get code => VStringCode.url;

  @override
  Map<String, dynamic>? validate(String value) {
    const String label = r'[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?';
    const String domain = '(?:$label\\.)+[A-Za-z]{2,}';
    const String host = '(?:$domain|localhost)';
    const String port = r'(?::[0-9]+)?';
    final String tail = hostOnly ? '' : r'(?:[/?#][^\s]*)?';

    final String schemePart;
    if (schemes.isEmpty) {
      schemePart = r'(?:[a-z][a-z0-9+.\-]*://)?';
    } else {
      final String alt = schemes.map(RegExp.escape).join('|');
      schemePart = '(?:$alt)://';
    }

    final RegExp regex = RegExp('^$schemePart$host$port$tail\$');

    return regex.hasMatch(value) ? null : {};
  }
}
