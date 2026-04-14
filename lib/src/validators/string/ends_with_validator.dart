import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

class EndsWithValidator extends Validator<String> {
  final String suffix;

  const EndsWithValidator({required this.suffix});

  @override
  String get code => VCode.endsWith;

  @override
  Map<String, dynamic>? validate(String value) =>
      value.endsWith(suffix) ? null : {'suffix': suffix};
}
