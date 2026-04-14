import 'package:validart/src/validators/validator.dart';

class LengthValidator extends Validator<String> {
  final int length;

  const LengthValidator({required this.length, required super.message});

  @override
  String get code => 'length';

  @override
  String? validate(String value) => value.length == length ? null : message;
}
