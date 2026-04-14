import 'package:validart/src/validators/validator.dart';

class UuidValidator extends Validator<String> {
  const UuidValidator({required super.message});

  @override
  String get code => 'invalid_uuid';

  @override
  String? validate(String value) {
    final regex = RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$');
    return regex.hasMatch(value) ? null : message;
  }
}
