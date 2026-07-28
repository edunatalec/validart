import '../../v_code.dart';
import '../validator.dart';

/// Validates that a number is at most [max].
class MaxValidator<T extends num> extends Validator<T> {
  /// Creates a [MaxValidator] with the given [max].
  const MaxValidator({required this.max});

  /// The maximum allowed value.
  final T max;

  @override
  String get code => VNumberCode.tooBig;

  @override
  Map<String, dynamic>? validate(T value) => value <= max ? null : {'max': max};
}
