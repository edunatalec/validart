import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

/// Validates that a number is at most [max].
class MaxValidator<T extends num> extends Validator<T> {
  /// The maximum allowed value.
  final T max;

  /// Creates a [MaxValidator] with the given [max].
  const MaxValidator({required this.max});

  @override
  String get code => VNumberCode.tooBig;

  @override
  Map<String, dynamic>? validate(T value) => value <= max ? null : {'max': max};
}
