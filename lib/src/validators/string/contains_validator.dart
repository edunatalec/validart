import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

/// Validates that a string contains the given [substring].
class ContainsValidator extends Validator<String> {
  /// The substring that must be present.
  final String substring;

  /// Creates a [ContainsValidator] with the given [substring].
  const ContainsValidator({required this.substring});

  @override
  String get code => VStringCode.contains;

  @override
  Map<String, dynamic>? validate(String value) =>
      value.contains(substring) ? null : {'substring': substring};
}
