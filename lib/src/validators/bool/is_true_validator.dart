import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

class IsTrueValidator extends Validator<bool> {
  const IsTrueValidator();

  @override
  String get code => VCode.isTrue;

  @override
  Map<String, dynamic>? validate(bool value) => value == true ? null : {};
}
