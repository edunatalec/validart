import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

/// Validates that a string has at least [min] characters.
class MinLengthValidator extends Validator<String> {
  /// The minimum allowed length.
  final int min;

  /// Creates a [MinLengthValidator] with the given [min] length.
  const MinLengthValidator({required this.min});

  @override
  String get code => VCode.stringTooSmall;

  @override
  Map<String, dynamic>? validate(String value) =>
      value.length >= min ? null : {'min': min};
}
