import 'package:validart/src/validators/validator.dart';

class AlphanumericValidator extends Validator<String> {
  const AlphanumericValidator({required super.message});

  @override
  String get code => 'alphanumeric';

  @override
  String? validate(String value) {
    final regex = RegExp(r'^[a-zA-Z0-9]+$');
    return regex.hasMatch(value) ? null : message;
  }
}
