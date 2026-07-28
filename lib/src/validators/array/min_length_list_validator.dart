import '../../v_code.dart';
import '../validator.dart';

/// Validates that a list has at least [min] elements.
class MinLengthListValidator<T> extends Validator<List<T>> {
  /// Creates a [MinLengthListValidator] with the given [min].
  const MinLengthListValidator({required this.min});

  /// The minimum number of elements allowed.
  final int min;

  @override
  String get code => VArrayCode.tooSmall;

  @override
  Map<String, dynamic>? validate(List<T> value) =>
      value.length >= min ? null : {'min': min};
}
