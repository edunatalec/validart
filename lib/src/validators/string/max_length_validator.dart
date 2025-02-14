import 'package:keeper/src/validators/validator.dart';

class MaxLengthValidator extends KValidator<String> {
  final int maxLength;

  MaxLengthValidator(this.maxLength, {required super.message});

  @override
  String? validate(String? value) {
    if (value != null && value.length > maxLength) return message;

    return null;
  }
}
