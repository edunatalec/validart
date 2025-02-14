import 'package:keeper/src/validators/validator.dart';

class CEPValidator extends KValidator<String> {
  CEPValidator({required super.message});

  @override
  String? validate(String? value) {
    if (value == null) return message;

    final cep = value.replaceAll(RegExp(r'[^\d]'), '');

    if (!RegExp(r'^\d{8}$').hasMatch(cep)) return message;

    if (RegExp(r'^(.)\1*$').hasMatch(cep)) return message;

    return null;
  }
}
