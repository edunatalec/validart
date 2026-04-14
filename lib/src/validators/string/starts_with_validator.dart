import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

class StartsWithValidator extends Validator<String> {
  final String prefix;

  const StartsWithValidator({required this.prefix});

  @override
  String get code => VCode.startsWith;

  @override
  Map<String, dynamic>? validate(String value) =>
      value.startsWith(prefix) ? null : {'prefix': prefix};
}
