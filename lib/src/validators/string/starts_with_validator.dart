import 'package:keeper/src/enums/case_sensitivity.dart';
import 'package:keeper/src/validators/validator.dart';

class StartsWithValidator extends KValidator<String> {
  final String prefix;
  final CaseSensitivity caseSensitivity;

  StartsWithValidator(
    this.prefix, {
    required super.message,
    this.caseSensitivity = CaseSensitivity.sensitive,
  });

  @override
  String? validate(String? value) {
    if (value == null) return message;

    final bool startsWith =
        caseSensitivity == CaseSensitivity.insensitive
            ? prefix.toLowerCase().startsWith(prefix.toLowerCase())
            : value.startsWith(prefix);

    return startsWith ? null : message;
  }
}
