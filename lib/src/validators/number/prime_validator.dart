import 'dart:math';

import 'package:validart/src/validators/validator.dart';

class PrimeValidator extends Validator<int> {
  const PrimeValidator({required super.message});

  @override
  String get code => 'prime';

  @override
  String? validate(int value) {
    if (value <= 1) return message;
    for (int i = 2; i <= sqrt(value).toInt(); i++) {
      if (value % i == 0) return message;
    }
    return null;
  }
}
