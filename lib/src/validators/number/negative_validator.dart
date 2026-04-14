import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

class NegativeValidator<T extends num> extends Validator<T> {
  const NegativeValidator();

  @override
  String get code => VCode.negative;

  @override
  Map<String, dynamic>? validate(T value) => value < 0 ? null : {};
}
