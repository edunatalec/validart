import 'package:validart/src/validators/validator.dart';

class IsFalseValidator extends Validator<bool> {
  const IsFalseValidator({required super.message});

  @override
  String get code => 'is_false';

  @override
  String? validate(bool value) => value == false ? null : message;
}
