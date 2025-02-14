import 'package:keeper/src/enums/case_sensitivity.dart';
import 'package:keeper/src/validators/validator.dart';

class EqualsValidator extends KValidator<String> {
  final String expectedValue;
  final CaseSensitivity caseSensitivity;

  EqualsValidator(
    this.expectedValue, {
    required super.message,
    this.caseSensitivity = CaseSensitivity.sensitive,
  });

  @override
  String? validate(String? value) {
    if (value == null) return message;

    final bool isEqual =
        caseSensitivity == CaseSensitivity.insensitive
            ? value.toLowerCase() == expectedValue.toLowerCase()
            : value == expectedValue;

    return isEqual ? null : message;
  }
}
