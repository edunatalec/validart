import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

class UniqueValidator<T> extends Validator<List<T>> {
  const UniqueValidator();

  @override
  String get code => VCode.unique;

  @override
  Map<String, dynamic>? validate(List<T> value) =>
      value.toSet().length == value.length ? null : {};
}
