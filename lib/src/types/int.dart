import 'package:keeper/src/messages/int_message.dart';
import 'package:keeper/src/types/number.dart';
import 'package:keeper/src/validators/int/even_validator.dart';
import 'package:keeper/src/validators/int/odd_validator.dart';
import 'package:keeper/src/validators/required_validator.dart';
import 'package:keeper/src/validators/validator.dart';

class KInt extends KNumber<int> {
  final IntMessage _message;

  KInt(this._message, {required String? message}) {
    add(RequiredValidator(message: message ?? _message.required));
  }

  @override
  KInt add(KValidator<int> validator) {
    super.add(validator);

    return this;
  }

  @override
  KInt min(int min, {String? message}) {
    super.min(min, message: message ?? _message.min(min));

    return this;
  }

  @override
  KInt max(int max, {String? message}) {
    super.max(max, message: message ?? _message.max(max));

    return this;
  }

  @override
  KInt positive({String? message}) {
    super.positive(message: message ?? _message.positive);

    return this;
  }

  @override
  KInt negative({String? message}) {
    super.negative(message: message ?? _message.negative);

    return this;
  }

  @override
  KInt between(int min, int max, {String? message}) {
    super.between(min, max, message: message ?? _message.between(min, max));

    return this;
  }

  @override
  KInt multipleOf(int factor, {String? message}) {
    super.multipleOf(factor, message: message ?? _message.multipleOf(factor));

    return this;
  }

  KInt even({String? message}) {
    return add(EvenValidator(message: message ?? _message.even));
  }

  KInt odd({String? message}) {
    return add(OddValidator(message: message ?? _message.odd));
  }

  @override
  KInt any(covariant List<KInt> types, {String? message}) {
    super.any(types, message: message ?? _message.any);

    return this;
  }

  @override
  KInt every(covariant List<KInt> types, {String? message}) {
    super.every(types, message: message ?? _message.every);

    return this;
  }

  @override
  KInt optional() {
    super.optional();

    return this;
  }

  @override
  KInt nullable() {
    super.nullable();

    return this;
  }

  @override
  KInt refine(bool Function(int? data) validator, {String? message}) {
    super.refine(validator, message: message ?? _message.refine);

    return this;
  }
}
