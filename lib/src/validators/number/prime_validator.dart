import 'dart:math';

import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

class PrimeValidator extends Validator<int> {
  const PrimeValidator();

  @override
  String get code => VCode.prime;

  @override
  Map<String, dynamic>? validate(int value) {
    if (value <= 1) return {};
    for (int i = 2; i <= sqrt(value).toInt(); i++) {
      if (value % i == 0) return {};
    }
    return null;
  }
}
