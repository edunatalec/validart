import 'package:validart/src/validators/validator.dart';

class ContainsAllValidator<T> extends Validator<List<T>> {
  final List<T> required;

  const ContainsAllValidator({required this.required, required super.message});

  @override
  String get code => 'contains';

  @override
  String? validate(List<T> value) =>
      required.every((r) => value.contains(r)) ? null : message;
}
