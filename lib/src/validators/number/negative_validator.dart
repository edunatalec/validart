import 'package:validart/src/validators/validator.dart';

class NegativeValidator<T extends num> extends Validator<T> {
  const NegativeValidator({required super.message});

  @override
  String get code => 'negative';

  @override
  String? validate(T value) => value < 0 ? null : message;
}
