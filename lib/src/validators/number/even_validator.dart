import 'package:validart/src/validators/validator.dart';

class EvenValidator extends Validator<int> {
  const EvenValidator({required super.message});

  @override
  String get code => 'even';

  @override
  String? validate(int value) => value % 2 == 0 ? null : message;
}
