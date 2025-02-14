import 'package:keeper/src/enums/case_sensitivity.dart';
import 'package:keeper/src/validators/validator.dart';

class ContainsValidator extends KValidator<String> {
  final String data;
  final CaseSensitivity caseSensitivity;

  ContainsValidator(
    this.data, {
    required super.message,
    this.caseSensitivity = CaseSensitivity.sensitive,
  });

  @override
  String? validate(String? value) {
    if (value == null) return message;

    final bool contains =
        caseSensitivity == CaseSensitivity.insensitive
            ? value.toLowerCase().contains(data.toLowerCase())
            : value.contains(data);

    return contains ? null : message;
  }
}
