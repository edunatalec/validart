import 'package:validart/src/validators/validator.dart';

class UrlValidator extends Validator<String> {
  const UrlValidator({required super.message});

  @override
  String get code => 'invalid_url';

  @override
  String? validate(String value) {
    final regex = RegExp(r'^https?://[^\s/$.?#].[^\s]*$');
    return regex.hasMatch(value) ? null : message;
  }
}
