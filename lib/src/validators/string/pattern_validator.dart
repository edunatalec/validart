import 'package:keeper/src/validators/validator.dart';

class PatternValidator extends KValidator<String> {
  final String pattern;

  PatternValidator(this.pattern, {required super.message});

  @override
  String? validate(value) {
    if (value == null) return message;
    if (RegExp(pattern).hasMatch(value)) return null;

    return message;
  }
}
