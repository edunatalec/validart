import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

class IsFalseValidator extends Validator<bool> {
  const IsFalseValidator();

  @override
  String get code => VCode.isFalse;

  @override
  Map<String, dynamic>? validate(bool value) => value == false ? null : {};
}
