import 'package:keeper/src/messages/num_message.dart';
import 'package:keeper/src/types/number.dart';
import 'package:keeper/src/validators/required_validator.dart';
import 'package:keeper/src/validators/validator.dart';

class KNum extends KNumber {
  final NumMessage _message;

  KNum(this._message, {required String? message}) {
    add(RequiredValidator(message: message ?? _message.required));
  }

  @override
  KNum add(KValidator<num> validator) {
    super.add(validator);

    return this;
  }

  @override
  KNum min(num min, {String? message}) {
    super.min(min, message: message ?? _message.min(min));

    return this;
  }

  @override
  KNum max(num max, {String? message}) {
    super.max(max, message: message ?? _message.max(max));

    return this;
  }

  @override
  KNum positive({String? message}) {
    super.positive(message: message ?? _message.positive);

    return this;
  }

  @override
  KNum negative({String? message}) {
    super.negative(message: message ?? _message.negative);

    return this;
  }

  @override
  KNum between(num min, num max, {String? message}) {
    super.between(min, max, message: message ?? _message.between(min, max));

    return this;
  }

  @override
  KNum multipleOf(num factor, {String? message}) {
    super.multipleOf(factor, message: message ?? _message.multipleOf(factor));

    return this;
  }

  @override
  KNum optional() {
    super.optional();

    return this;
  }

  @override
  KNum nullable() {
    super.nullable();

    return this;
  }

  @override
  KNum refine(bool Function(num? data) validator, {String? message}) {
    super.refine(validator, message: message ?? _message.refine);

    return this;
  }
}
