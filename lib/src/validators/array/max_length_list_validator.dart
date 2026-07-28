import '../../v_code.dart';
import '../validator.dart';

/// Validates that a list has at most [max] elements.
class MaxLengthListValidator<T> extends Validator<List<T>> {
  /// Creates a [MaxLengthListValidator] with the given [max].
  const MaxLengthListValidator({required this.max});

  /// The maximum number of elements allowed.
  final int max;

  @override
  String get code => VArrayCode.tooBig;

  @override
  Map<String, dynamic>? validate(List<T> value) =>
      value.length <= max ? null : {'max': max};
}
