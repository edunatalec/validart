import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

class PatternValidator extends Validator<String> {
  final String pattern;

  const PatternValidator({required this.pattern});

  @override
  String get code => VCode.invalidFormat;

  @override
  Map<String, dynamic>? validate(String value) {
    final regex = RegExp(pattern);
    return regex.hasMatch(value) ? null : {'pattern': pattern};
  }
}
