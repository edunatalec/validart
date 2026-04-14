import 'package:validart/src/validators/validator.dart';

class MaxLengthListValidator<T> extends Validator<List<T>> {
  final int max;

  const MaxLengthListValidator({required this.max, required super.message});

  @override
  String get code => 'too_big';

  @override
  String? validate(List<T> value) => value.length <= max ? null : message;
}
