import 'package:validart/src/validators/validator.dart';

/// A validator that ensures a given `num` value is a multiple of a specified factor.
///
/// The `MultipleOfValidator` checks whether the provided value is a multiple of [factor].
/// If the value is valid, the validation passes (`null` is returned).
/// Otherwise, it returns the provided error [message].
///
/// Example usage:
/// ```dart
/// final validator = MultipleOfValidator(5, message: 'Value must be a multiple of 5');
///
/// print(validator.validate(10));  // null (valid)
/// print(validator.validate(15));  // null (valid)
/// print(validator.validate(7));   // 'Value must be a multiple of 5' (invalid)
/// print(validator.validate(null)); // 'Value must be a multiple of 5' (invalid)
/// ```
class MultipleOfValidator<T extends num> extends Validator<T> {
  /// The factor that the value must be a multiple of.
  final T factor;

  /// Creates a `MultipleOfValidator` that ensures values are a multiple of [factor].
  ///
  /// The [message] will be returned if validation fails.
  MultipleOfValidator(this.factor, {required super.message});

  /// Validates whether the given [value] is a multiple of [factor].
  ///
  /// Returns `null` if the value is a valid multiple, otherwise returns the validation message.
  @override
  String? validate(covariant T value) {
    if (value % factor != 0) return message;

    return null;
  }
}
