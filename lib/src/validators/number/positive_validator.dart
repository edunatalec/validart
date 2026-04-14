import 'package:validart/src/validators/validator.dart';

class PositiveValidator<T extends num> extends Validator<T> {
  const PositiveValidator({required super.message});

  @override
  String get code => 'positive';

  @override
  String? validate(T value) => value > 0 ? null : message;
}
