import '../../v_code.dart';
import '../validator.dart';

/// Validates that a string is equal to the [expected] value.
class EqualsValidator extends Validator<String> {
  /// Creates an [EqualsValidator] with the given [expected] value.
  const EqualsValidator({required this.expected});

  /// The expected string value.
  final String expected;

  @override
  String get code => VStringCode.equals;

  @override
  Map<String, dynamic>? validate(String value) =>
      value == expected ? null : {'expected': expected};
}
