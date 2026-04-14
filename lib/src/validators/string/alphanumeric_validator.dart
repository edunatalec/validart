import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

class AlphanumericValidator extends Validator<String> {
  const AlphanumericValidator();

  @override
  String get code => VCode.alphanumeric;

  @override
  Map<String, dynamic>? validate(String value) {
    final regex = RegExp(r'^[a-zA-Z0-9]+$');
    return regex.hasMatch(value) ? null : {};
  }
}
