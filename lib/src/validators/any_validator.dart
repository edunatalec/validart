import 'package:validart/src/types/type.dart';
import 'package:validart/src/validators/validator.dart';

/// A validator that checks if a value satisfies at least one of the given types.
///
/// This validator is useful when you want a value to match at least one of
/// multiple possible validation rules.
///
/// Example:
/// ```dart
/// final validator = v.string().any([
///   v.string().email(),
///   v.string().url(),
/// ], message: 'Must be an email or URL');
///
/// print(validator.validate('test@example.com')); // true
/// print(validator.validate('https://example.com')); // true
/// print(validator.validate('invalid-string')); // false
/// ```
class AnyValidator<T> extends Validator<T> {
  /// A list of types that the value can match.
  final List<VType<T>> types;

  /// Creates an [AnyValidator] with a list of valid types.
  ///
  /// If the value matches any of the types, the validation passes.
  AnyValidator(this.types, {required super.message});

  @override
  validate(value) {
    for (final type in types) {
      final message = type.getErrorMessage(value);

      if (message == null) return null;
    }

    return message;
  }
}
