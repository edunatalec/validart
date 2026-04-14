import 'package:validart/src/validators/validator.dart';

class MinLengthValidator extends Validator<String> {
  final int min;

  const MinLengthValidator({required this.min, required super.message});

  @override
  String get code => 'too_small';

  @override
  String? validate(String value) => value.length >= min ? null : message;
}
