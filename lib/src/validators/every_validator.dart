import 'package:keeper/src/types/type.dart';
import 'package:keeper/src/validators/validator.dart';

/// A validator that ensures a value satisfies all the given types.
///
/// This validator is useful when a value needs to pass multiple validation rules simultaneously.
///
/// Example:
/// ```dart
/// final validator = k.string().every([
///   k.string().min(5),
///   k.string().max(10),
/// ], message: 'Must be between 5 and 10 characters');
///
/// print(validator.validate('abcdef')); // true
/// print(validator.validate('abc')); // false
/// print(validator.validate('abcdefghijk')); // false
/// ```
class EveryValidator<T> extends KValidator<T> {
  /// A list of types that the value must satisfy.
  final List<KType<T>> types;

  /// Creates an [EveryValidator] with a list of required validation types.
  ///
  /// The value must pass all provided validation types to be considered valid.
  EveryValidator(this.types, {required super.message});

  @override
  String? validate(value) {
    for (final type in types) {
      final message = type.getErrorMessage(value);

      if (message != null) return message;
    }

    return null;
  }
}
