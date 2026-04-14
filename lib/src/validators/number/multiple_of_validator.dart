import 'package:validart/src/validators/validator.dart';

class MultipleOfValidator<T extends num> extends Validator<T> {
  final T factor;

  const MultipleOfValidator({required this.factor, required super.message});

  @override
  String get code => 'multiple_of';

  @override
  String? validate(T value) => value % factor == 0 ? null : message;
}
