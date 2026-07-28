import '../../v_code.dart';
import '../validator.dart';

/// Validates that a string contains the given [substring].
class ContainsValidator extends Validator<String> {
  /// Creates a [ContainsValidator] with the given [substring].
  const ContainsValidator({required this.substring});

  /// The substring that must be present.
  final String substring;

  @override
  String get code => VStringCode.contains;

  @override
  Map<String, dynamic>? validate(String value) =>
      value.contains(substring) ? null : {'substring': substring};
}
