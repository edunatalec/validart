import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

class MultipleOfValidator<T extends num> extends Validator<T> {
  final T factor;

  const MultipleOfValidator({required this.factor});

  @override
  String get code => VCode.multipleOf;

  @override
  Map<String, dynamic>? validate(T value) =>
      value % factor == 0 ? null : {'factor': factor};
}
