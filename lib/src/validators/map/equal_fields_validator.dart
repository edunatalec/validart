import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

class EqualFieldsValidator extends Validator<Map<String, dynamic>> {
  final String field;
  final String other;

  const EqualFieldsValidator({required this.field, required this.other});

  @override
  String get code => VCode.fieldsNotEqual;

  @override
  Map<String, dynamic>? validate(Map<String, dynamic> value) =>
      value[field] == value[other] ? null : {'field': field, 'other': other};
}
