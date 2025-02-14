import 'package:keeper/src/validators/validator.dart';

class MinLengthValidator extends KValidator<String> {
  final int minLength;

  MinLengthValidator(this.minLength, {required super.message});

  @override
  String? validate(String? value) {
    if (value == null || value.length < minLength) return message;

    return null;
  }
}
