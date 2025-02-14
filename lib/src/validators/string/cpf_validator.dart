import 'package:keeper/src/validators/validator.dart';

class CPFValidator extends KValidator<String> {
  CPFValidator({required super.message});

  @override
  String? validate(String? value) {
    if (value == null) return message;

    final cpf = value.replaceAll(RegExp(r'[^\d]'), '');

    if (cpf.length != 11 || RegExp(r'^(.)\1*$').hasMatch(cpf)) {
      return message;
    }

    if (!_validateCPF(cpf)) return message;

    return null;
  }

  bool _validateCPF(String cpf) {
    int sum1 = 0, sum2 = 0;

    for (int i = 0; i < 9; i++) {
      sum1 += int.parse(cpf[i]) * (10 - i);
      sum2 += int.parse(cpf[i]) * (11 - i);
    }

    final int checkDigit1 = (sum1 * 10) % 11 % 10;
    sum2 += checkDigit1 * 2;
    final int checkDigit2 = (sum2 * 10) % 11 % 10;

    return cpf[9] == checkDigit1.toString() &&
        cpf[10] == checkDigit2.toString();
  }
}
