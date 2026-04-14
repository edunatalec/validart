import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

class ContainsAllValidator<T> extends Validator<List<T>> {
  final List<T> required;

  const ContainsAllValidator({required this.required});

  @override
  String get code => VCode.containsAll;

  @override
  Map<String, dynamic>? validate(List<T> value) =>
      required.every((r) => value.contains(r)) ? null : {};
}
