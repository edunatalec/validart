import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

class OddValidator extends Validator<int> {
  const OddValidator();

  @override
  String get code => VCode.odd;

  @override
  Map<String, dynamic>? validate(int value) => value % 2 != 0 ? null : {};
}
