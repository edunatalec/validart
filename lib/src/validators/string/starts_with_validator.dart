import 'package:keeper/src/validators/validator.dart';

class StartsWithValidator extends KValidator<String> {
  final String prefix;

  StartsWithValidator(this.prefix, {required super.message});

  @override
  String? validate(String? value) {
    if (value == null || !value.startsWith(prefix)) return message;

    return null;
  }
}
