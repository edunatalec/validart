import 'package:validart/src/validators/string/pattern_validator.dart';

/// A validator that checks whether a given string is a valid slug.
///
/// A slug is typically used in URLs and should contain only:
/// - Lowercase letters (`a-z`)
/// - Numbers (`0-9`)
/// - Hyphens (`-`)
///
/// ### Example
/// ```dart
/// final slugValidator = SlugValidator(message: 'Invalid slug format');
///
/// print(slugValidator.validate('valid-slug-123')); // null (valid)
/// print(slugValidator.validate('Invalid Slug!')); // 'Invalid slug format' (invalid)
/// print(slugValidator.validate('slug_with_underscores')); // 'Invalid slug format' (invalid)
/// ```
///
/// ## Parameters:
/// - [message]: Custom error message when validation fails.
///
/// ## Slug Format:
/// - Must contain only lowercase letters, numbers, and hyphens.
/// - Cannot have consecutive hyphens (`--`).
/// - Cannot start or end with a hyphen (`-`).
class SlugValidator extends PatternValidator {
  /// Creates a `SlugValidator` to check if a string is a valid slug.
  ///
  /// - Requires a [message] to specify the validation error.
  SlugValidator({required super.message}) : super(r'^[a-z0-9]+(-[a-z0-9]+)*$');
}
