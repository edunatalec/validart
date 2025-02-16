import 'package:keeper/src/validators/validator.dart';

/// A validator that ensures a given `double` value is finite (not infinite or NaN).
///
/// The `FiniteValidator` checks if the provided value is neither `double.infinity` nor `double.nan`.
/// If the value is finite, validation passes (`null` is returned). Otherwise, it returns the provided error [message].
///
/// Example usage:
/// ```dart
/// final validator = FiniteValidator(message: 'The number must be finite');
///
/// print(validator.validate(3.14)); // null (valid)
/// print(validator.validate(-100.5)); // null (valid)
/// print(validator.validate(double.infinity)); // 'The number must be finite' (invalid)
/// print(validator.validate(double.nan)); // 'The number must be finite' (invalid)
/// print(validator.validate(null)); // 'The number must be finite' (invalid)
/// ```
class FiniteValidator extends KValidator<double> {
  /// Creates a `FiniteValidator` with a required error message.
  FiniteValidator({required super.message});

  /// Validates whether the given [value] is finite.
  ///
  /// Returns `null` if the value is neither `double.infinity` nor `double.nan`,
  /// otherwise returns the validation message.
  @override
  String? validate(value) {
    if (value == null || value.isInfinite || value.isNaN) return message;

    return null;
  }
}
