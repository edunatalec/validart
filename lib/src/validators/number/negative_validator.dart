import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

/// Validates that a number is negative.
class NegativeValidator<T extends num> extends Validator<T> {
  /// Creates a [NegativeValidator].
  const NegativeValidator();

  @override
  String get code => VNumberCode.negative;

  @override
  Map<String, dynamic>? validate(T value) => value < 0 ? null : {};
}
