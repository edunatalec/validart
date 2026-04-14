import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

class AlphaValidator extends Validator<String> {
  const AlphaValidator();

  @override
  String get code => VCode.alpha;

  @override
  Map<String, dynamic>? validate(String value) {
    final regex = RegExp(r'^[a-zA-Z]+$');
    return regex.hasMatch(value) ? null : {};
  }
}
