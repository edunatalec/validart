import 'package:keeper/src/types/refine.dart';
import 'package:keeper/src/validators/num/between_validator.dart';
import 'package:keeper/src/validators/num/max_validator.dart';
import 'package:keeper/src/validators/num/min_validator.dart';
import 'package:keeper/src/validators/num/multiple_of_validator.dart';
import 'package:keeper/src/validators/num/negative_validator.dart';
import 'package:keeper/src/validators/num/positive_validator.dart';

class KNumber<T extends num> extends KRefine<T> {
  KNumber min(T min, {String? message}) {
    add(MinValidator(min, message: message!));

    return this;
  }

  KNumber max(T max, {String? message}) {
    add(MaxValidator(max, message: message!));

    return this;
  }

  KNumber positive({String? message}) {
    add(PositiveValidator(message: message!));

    return this;
  }

  KNumber negative({String? message}) {
    add(NegativeValidator(message: message!));

    return this;
  }

  KNumber between(T min, T max, {String? message}) {
    add(BetweenValidator(min, max, message: message!));

    return this;
  }

  KNumber multipleOf(T factor, {String? message}) {
    add(MultipleOfValidator(factor, message: message!));

    return this;
  }
}
