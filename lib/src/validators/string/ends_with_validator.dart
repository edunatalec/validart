import '../../v_code.dart';
import '../validator.dart';

/// Validates that a string ends with the given [suffix].
class EndsWithValidator extends Validator<String> {
  /// Creates an [EndsWithValidator] with the given [suffix].
  const EndsWithValidator({required this.suffix});

  /// The suffix the string must end with.
  final String suffix;

  @override
  String get code => VStringCode.endsWith;

  @override
  Map<String, dynamic>? validate(String value) =>
      value.endsWith(suffix) ? null : {'suffix': suffix};
}
