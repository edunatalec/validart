import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

class UrlValidator extends Validator<String> {
  const UrlValidator();

  @override
  String get code => VCode.invalidUrl;

  @override
  Map<String, dynamic>? validate(String value) {
    final regex = RegExp(r'^https?://[^\s/$.?#].[^\s]*$');
    return regex.hasMatch(value) ? null : {};
  }
}
