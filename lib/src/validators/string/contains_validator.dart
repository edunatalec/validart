import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

class ContainsValidator extends Validator<String> {
  final String substring;

  const ContainsValidator({required this.substring});

  @override
  String get code => VCode.contains;

  @override
  Map<String, dynamic>? validate(String value) =>
      value.contains(substring) ? null : {'substring': substring};
}
