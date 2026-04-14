import 'package:validart/src/validators/validator.dart';

class EqualsValidator extends Validator<String> {
  final String expected;

  const EqualsValidator({required this.expected, required super.message});

  @override
  String get code => 'equals';

  @override
  String? validate(String value) => value == expected ? null : message;
}
