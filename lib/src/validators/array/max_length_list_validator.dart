import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

/// Validates that a list has at most [max] elements.
class MaxLengthListValidator<T> extends Validator<List<T>> {
  /// The maximum number of elements allowed.
  final int max;

  /// Creates a [MaxLengthListValidator] with the given [max].
  const MaxLengthListValidator({required this.max});

  @override
  String get code => VCode.arrayTooBig;

  @override
  Map<String, dynamic>? validate(List<T> value) =>
      value.length <= max ? null : {'max': max};
}
