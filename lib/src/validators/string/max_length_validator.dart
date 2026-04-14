import 'package:validart/src/validators/validator.dart';

class MaxLengthValidator extends Validator<String> {
  final int max;

  const MaxLengthValidator({required this.max, required super.message});

  @override
  String get code => 'too_big';

  @override
  String? validate(String value) => value.length <= max ? null : message;
}
