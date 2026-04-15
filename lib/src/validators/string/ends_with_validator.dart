import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

/// Validates that a string ends with the given [suffix].
class EndsWithValidator extends Validator<String> {
  /// The suffix the string must end with.
  final String suffix;

  /// Creates an [EndsWithValidator] with the given [suffix].
  const EndsWithValidator({required this.suffix});

  @override
  String get code => VCode.endsWith;

  @override
  Map<String, dynamic>? validate(String value) =>
      value.endsWith(suffix) ? null : {'suffix': suffix};
}
