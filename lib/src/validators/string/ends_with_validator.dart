import 'package:validart/src/validators/validator.dart';

class EndsWithValidator extends Validator<String> {
  final String suffix;

  const EndsWithValidator({required this.suffix, required super.message});

  @override
  String get code => 'ends_with';

  @override
  String? validate(String value) => value.endsWith(suffix) ? null : message;
}
