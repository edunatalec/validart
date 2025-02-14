import 'package:keeper/src/validators/validator.dart';

class CNPJValidator extends KValidator<String> {
  CNPJValidator({required super.message});

  @override
  String? validate(String? value) {
    if (value == null) return message;

    final cnpj = value.replaceAll(RegExp(r'[^\d]'), '');

    if (cnpj.length != 14 || RegExp(r'^(.)\1*$').hasMatch(cnpj)) {
      return message;
    }

    if (!_validateCNPJ(cnpj)) return message;

    return null;
  }

  bool _validateCNPJ(String cnpj) {
    final List<int> weights1 = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    final List<int> weights2 = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];

    int sum1 = 0, sum2 = 0;

    for (int i = 0; i < 12; i++) {
      sum1 += int.parse(cnpj[i]) * weights1[i];
    }

    final int checkDigit1 = (sum1 % 11 < 2) ? 0 : (11 - sum1 % 11);

    for (int i = 0; i < 13; i++) {
      sum2 += int.parse(cnpj[i]) * weights2[i];
    }

    final int checkDigit2 = (sum2 % 11 < 2) ? 0 : (11 - sum2 % 11);

    return cnpj[12] == checkDigit1.toString() &&
        cnpj[13] == checkDigit2.toString();
  }
}
