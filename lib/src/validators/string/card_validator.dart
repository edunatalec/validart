import 'package:validart/src/validators/validator.dart';

class CardValidator extends Validator<String> {
  const CardValidator({required super.message});

  @override
  String get code => 'card';

  @override
  String? validate(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 13 || digits.length > 19) return message;

    int sum = 0;
    bool alternate = false;

    for (int i = digits.length - 1; i >= 0; i--) {
      int n = int.parse(digits[i]);
      if (alternate) {
        n *= 2;
        if (n > 9) n -= 9;
      }
      sum += n;
      alternate = !alternate;
    }

    return (sum % 10 == 0) ? null : message;
  }
}
