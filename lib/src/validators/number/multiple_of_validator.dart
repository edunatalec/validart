import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

/// Validates that a number is a multiple of [factor].
class MultipleOfValidator<T extends num> extends Validator<T> {
  /// The factor the value must be a multiple of.
  final T factor;

  /// Creates a [MultipleOfValidator] with the given [factor].
  const MultipleOfValidator({required this.factor});

  @override
  String get code => VCode.multipleOf;

  @override
  Map<String, dynamic>? validate(T value) {
    final remainder = (value % factor).abs();
    const epsilon = 1e-10;

    if (remainder < epsilon) return null;
    if ((factor.abs() - remainder) < epsilon) return null;

    return {'factor': factor};
  }
}
