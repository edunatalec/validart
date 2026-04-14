import 'package:validart/src/validators/validator.dart';

class UniqueValidator<T> extends Validator<List<T>> {
  const UniqueValidator({required super.message});

  @override
  String get code => 'unique';

  @override
  String? validate(List<T> value) =>
      value.toSet().length == value.length ? null : message;
}
