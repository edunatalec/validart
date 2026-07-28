import 'dart:math';

import '../../v_code.dart';
import '../validator.dart';

/// Validates that a number is prime.
class PrimeValidator extends Validator<int> {
  /// Creates a [PrimeValidator].
  const PrimeValidator();

  @override
  String get code => VIntCode.prime;

  @override
  Map<String, dynamic>? validate(int value) {
    if (value <= 1) return {};
    for (int i = 2; i <= sqrt(value).toInt(); i++) {
      if (value % i == 0) return {};
    }
    return null;
  }
}
