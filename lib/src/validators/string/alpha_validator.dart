import 'package:validart/src/validators/validator.dart';

class AlphaValidator extends Validator<String> {
  const AlphaValidator({required super.message});

  @override
  String get code => 'alpha';

  @override
  String? validate(String value) {
    final regex = RegExp(r'^[a-zA-Z]+$');
    return regex.hasMatch(value) ? null : message;
  }
}
