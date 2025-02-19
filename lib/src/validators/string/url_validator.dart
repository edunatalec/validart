import 'package:validart/src/validators/string/pattern_validator.dart';

/// A validator that checks whether a given string is a valid URL.
///
/// The `UrlValidator` ensures that the input follows a standard URL format,
/// supporting various protocols, domain structures, and query parameters.
///
/// ### Example
/// ```dart
/// final urlValidator = UrlValidator(message: 'Invalid URL');
///
/// print(urlValidator.validate('https://example.com')); // null (valid)
/// print(urlValidator.validate('http://google.com/search?q=dart')); // null (valid)
/// print(urlValidator.validate('ftp://files.example.com')); // null (valid)
/// print(urlValidator.validate('invalid-url')); // 'Invalid URL' (invalid)
/// ```
///
/// ## Parameters:
/// - [message]: Custom error message when validation fails.
///
/// ## URL Formats Supported:
/// - `http://example.com`
/// - `https://example.com`
/// - `ftp://example.com`
/// - `https://sub.domain.com/path?query=123`
///
/// **Note:** This regex does not enforce the presence of protocols like `http://`
/// but ensures a valid domain and path structure.
class UrlValidator extends PatternValidator {
  /// Creates a `UrlValidator` to check if a string is a valid URL.
  ///
  /// - Requires a [message] to specify the validation error.
  UrlValidator({required super.message})
      : super(
          r'[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)',
        );
}
