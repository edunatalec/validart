import 'package:keeper/src/validators/validator.dart';

class EndsWithValidator extends KValidator<String> {
  final String suffix;

  EndsWithValidator(this.suffix, {required super.message});

  @override
  String? validate(String? value) {
    if (value == null || !value.endsWith(suffix)) return message;

    return null;
  }
}
