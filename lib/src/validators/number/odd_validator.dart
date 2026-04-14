import 'package:validart/src/validators/validator.dart';

class OddValidator extends Validator<int> {
  const OddValidator({required super.message});

  @override
  String get code => 'odd';

  @override
  String? validate(int value) => value % 2 != 0 ? null : message;
}
