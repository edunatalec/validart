import 'package:validart/src/validators/validator.dart';

class PatternValidator extends Validator<String> {
  final String pattern;

  const PatternValidator({required this.pattern, required super.message});

  @override
  String get code => 'invalid_format';

  @override
  String? validate(String value) {
    final regex = RegExp(pattern);
    return regex.hasMatch(value) ? null : message;
  }
}
