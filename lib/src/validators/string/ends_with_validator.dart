import 'package:keeper/src/enums/case_sensitivity.dart';
import 'package:keeper/src/validators/validator.dart';

class EndsWithValidator extends KValidator<String> {
  final String suffix;
  final CaseSensitivity caseSensitivity;

  EndsWithValidator(
    this.suffix, {
    required super.message,
    this.caseSensitivity = CaseSensitivity.sensitive,
  });

  @override
  String? validate(String? value) {
    if (value == null) return message;

    final bool endsWith =
        caseSensitivity == CaseSensitivity.insensitive
            ? suffix.toLowerCase().endsWith(suffix.toLowerCase())
            : value.endsWith(suffix);

    return endsWith ? null : message;
  }
}
