import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

class NotEmptyValidator extends Validator<String> {
  const NotEmptyValidator();

  @override
  String get code => VCode.notEmpty;

  @override
  Map<String, dynamic>? validate(String value) => value.isNotEmpty ? null : {};
}
