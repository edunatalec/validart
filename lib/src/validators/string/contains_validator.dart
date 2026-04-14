import 'package:validart/src/validators/validator.dart';

class ContainsValidator extends Validator<String> {
  final String substring;

  const ContainsValidator({required this.substring, required super.message});

  @override
  String get code => 'contains';

  @override
  String? validate(String value) => value.contains(substring) ? null : message;
}
