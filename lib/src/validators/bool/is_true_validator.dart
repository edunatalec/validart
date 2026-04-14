import 'package:validart/src/validators/validator.dart';

class IsTrueValidator extends Validator<bool> {
  const IsTrueValidator({required super.message});

  @override
  String get code => 'is_true';

  @override
  String? validate(bool value) => value == true ? null : message;
}
