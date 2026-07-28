import '../../v_code.dart';
import '../validator.dart';

/// Validates that a number is between [min] and [max] (inclusive).
class BetweenValidator<T extends num> extends Validator<T> {
  /// Creates a [BetweenValidator] with the given [min] and [max].
  const BetweenValidator({
    required this.min,
    required this.max,
  });

  /// The minimum allowed value.
  final T min;

  /// The maximum allowed value.
  final T max;

  @override
  String get code => VNumberCode.notInRange;

  @override
  Map<String, dynamic>? validate(T value) =>
      value >= min && value <= max ? null : {'min': min, 'max': max};
}
