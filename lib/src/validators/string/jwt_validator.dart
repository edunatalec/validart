import 'package:validart/src/validators/validator.dart';

class JwtValidator extends Validator<String> {
  const JwtValidator({required super.message});

  @override
  String get code => 'jwt';

  @override
  String? validate(String value) {
    final regex = RegExp(r'^[A-Za-z0-9-_]+\.[A-Za-z0-9-_]+\.[A-Za-z0-9-_]+$');
    return regex.hasMatch(value) ? null : message;
  }
}
