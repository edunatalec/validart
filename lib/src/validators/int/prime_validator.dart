import 'package:validart/src/validators/validator.dart';

/// A validator that checks whether a given integer is a prime number.
///
/// A prime number is a natural number greater than 1 that has no divisors
/// other than 1 and itself.
///
/// ### Example
/// ```dart
/// final primeValidator = PrimeValidator(message: 'The number must be prime');
///
/// print(primeValidator.validate(2)); // null (valid)
/// print(primeValidator.validate(13)); // null (valid)
/// print(primeValidator.validate(4)); // 'The number must be prime' (invalid)
/// print(primeValidator.validate(9)); // 'The number must be prime' (invalid)
/// ```
///
/// ### Parameters
/// - [message]: Custom error message when validation fails.
class PrimeValidator extends ValidatorWithMessage<int> {
  /// Creates a `PrimeValidator` to check if an integer is a prime number.
  PrimeValidator({required super.message});

  @override
  String? validate(covariant int value) {
    if (value < 2) return message;

    for (int i = 2; i * i <= value; i++) {
      if (value % i == 0) return message;
    }

    return null;
  }
}
