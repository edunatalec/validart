import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

class EvenValidator extends Validator<int> {
  const EvenValidator();

  @override
  String get code => VCode.even;

  @override
  Map<String, dynamic>? validate(int value) => value % 2 == 0 ? null : {};
}
