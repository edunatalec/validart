import 'package:validart/src/validators/validator.dart';

class BetweenValidator<T extends num> extends Validator<T> {
  final T min;
  final T max;

  const BetweenValidator({
    required this.min,
    required this.max,
    required super.message,
  });

  @override
  String get code => 'not_in_range';

  @override
  String? validate(T value) => value >= min && value <= max ? null : message;
}
