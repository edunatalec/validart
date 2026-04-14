import 'package:validart/src/validators/validator.dart';

class MinLengthListValidator<T> extends Validator<List<T>> {
  final int min;

  const MinLengthListValidator({required this.min, required super.message});

  @override
  String get code => 'too_small';

  @override
  String? validate(List<T> value) => value.length >= min ? null : message;
}
