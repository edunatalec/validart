import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

/// Validates that a number is at least [min].
class MinValidator<T extends num> extends Validator<T> {
  /// The minimum allowed value.
  final T min;

  /// Creates a [MinValidator] with the given [min].
  const MinValidator({required this.min});

  @override
  String get code => VNumberCode.tooSmall;

  @override
  Map<String, dynamic>? validate(T value) => value >= min ? null : {'min': min};
}
