import '../../v_code.dart';
import '../validator.dart';

/// Validates that a number is at least [min].
class MinValidator<T extends num> extends Validator<T> {
  /// Creates a [MinValidator] with the given [min].
  const MinValidator({required this.min});

  /// The minimum allowed value.
  final T min;

  @override
  String get code => VNumberCode.tooSmall;

  @override
  Map<String, dynamic>? validate(T value) => value >= min ? null : {'min': min};
}
