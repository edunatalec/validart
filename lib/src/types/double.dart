import 'package:keeper/src/messages/double_message.dart';
import 'package:keeper/src/types/number.dart';
import 'package:keeper/src/validators/double/decimal_validator.dart';
import 'package:keeper/src/validators/double/finite_validator.dart';
import 'package:keeper/src/validators/double/integer_validator.dart';
import 'package:keeper/src/validators/required_validator.dart';
import 'package:keeper/src/validators/validator.dart';

class KDouble extends KNumber<double> {
  final DoubleMessage _message;

  KDouble(this._message, {required String? message}) {
    add(RequiredValidator(message: message ?? _message.required));
  }

  @override
  KDouble add(KValidator<double> validator) {
    super.add(validator);

    return this;
  }

  @override
  KDouble min(double min, {String? message}) {
    super.min(min, message: message ?? _message.min(min));

    return this;
  }

  @override
  KDouble max(double max, {String? message}) {
    super.max(max, message: message ?? _message.max(max));

    return this;
  }

  @override
  KDouble positive({String? message}) {
    super.positive(message: message ?? _message.positive);

    return this;
  }

  @override
  KDouble negative({String? message}) {
    super.negative(message: message ?? _message.negative);

    return this;
  }

  @override
  KDouble between(double min, double max, {String? message}) {
    super.between(min, max, message: message ?? _message.between(min, max));

    return this;
  }

  @override
  KDouble multipleOf(double factor, {String? message}) {
    super.multipleOf(factor, message: message ?? _message.multipleOf(factor));

    return this;
  }

  KDouble decimal({String? message}) {
    return add(DecimalValidator(message: message ?? _message.decimal));
  }

  KDouble finite({String? message}) {
    return add(FiniteValidator(message: message ?? _message.decimal));
  }

  KDouble integer({String? message}) {
    return add(IntegerValidator(message: message ?? _message.decimal));
  }

  @override
  KDouble any(covariant List<KDouble> types, {String? message}) {
    super.any(types, message: message ?? _message.any);

    return this;
  }

  @override
  KDouble every(covariant List<KDouble> types, {String? message}) {
    super.every(types, message: message ?? _message.every);

    return this;
  }

  @override
  KDouble optional() {
    super.optional();

    return this;
  }

  @override
  KDouble nullable() {
    super.nullable();

    return this;
  }

  @override
  KDouble refine(bool Function(double? data) validator, {String? message}) {
    super.refine(validator, message: message ?? _message.refine);

    return this;
  }
}
