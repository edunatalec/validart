import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

/// Validates that a string has at most [max] characters.
class MaxLengthValidator extends Validator<String> {
  /// The maximum allowed length.
  final int max;

  /// Creates a [MaxLengthValidator] with the given [max] length.
  const MaxLengthValidator({required this.max});

  @override
  String get code => VStringCode.tooBig;

  @override
  Map<String, dynamic>? validate(String value) =>
      value.length <= max ? null : {'max': max};
}
