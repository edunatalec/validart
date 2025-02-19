import 'package:validart/src/validators/validator.dart';

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
class FiniteValidator extends ValidatorWithMessage<double> {
  /// Creates a `FiniteValidator` with a required error message.
  FiniteValidator({required super.message});

  @override
  String? validate(covariant double value) {
    if (value.isInfinite || value.isNaN) return message;

    return null;
  }
}
