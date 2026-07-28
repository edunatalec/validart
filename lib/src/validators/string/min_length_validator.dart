import '../../v_code.dart';
import '../validator.dart';

/// Validates that a string has at least [min] characters.
class MinLengthValidator extends Validator<String> {
  /// Creates a [MinLengthValidator] with the given [min] length.
  const MinLengthValidator({required this.min});

  /// The minimum allowed length.
  final int min;

  @override
  String get code => VStringCode.tooSmall;

  @override
  Map<String, dynamic>? validate(String value) =>
      value.length >= min ? null : {'min': min};
}
