import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

/// Validates that a list has at least [min] elements.
class MinLengthListValidator<T> extends Validator<List<T>> {
  /// The minimum number of elements allowed.
  final int min;

  /// Creates a [MinLengthListValidator] with the given [min].
  const MinLengthListValidator({required this.min});

  @override
  String get code => VArrayCode.tooSmall;

  @override
  Map<String, dynamic>? validate(List<T> value) =>
      value.length >= min ? null : {'min': min};
}
