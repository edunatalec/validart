import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

class PositiveValidator<T extends num> extends Validator<T> {
  const PositiveValidator();

  @override
  String get code => VCode.positive;

  @override
  Map<String, dynamic>? validate(T value) => value > 0 ? null : {};
}
