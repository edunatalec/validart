import 'package:keeper/src/messages/bool_message.dart';
import 'package:keeper/src/types/refine.dart';
import 'package:keeper/src/validators/bool/is_false_validator.dart';
import 'package:keeper/src/validators/bool/is_true_validator.dart';
import 'package:keeper/src/validators/required_validator.dart';
import 'package:keeper/src/validators/validator.dart';

class KBool extends KRefine<bool> {
  final BoolMessage _message;

  KBool(this._message, {required String? message}) {
    add(RequiredValidator(message: message ?? _message.required));
  }

  @override
  KBool add(KValidator<bool> validator) {
    super.add(validator);

    return this;
  }

  KBool isTrue({String? message}) {
    return add(IsTrueValidator(message: message ?? _message.isTrue));
  }

  KBool isFalse({String? message}) {
    return add(IsFalseValidator(message: message ?? _message.isFalse));
  }

  @override
  KBool optional() {
    super.optional();

    return this;
  }

  @override
  KBool nullable() {
    super.nullable();

    return this;
  }

  @override
  KBool refine(bool Function(bool? data) validator, {String? message}) {
    super.refine(validator, message: message ?? _message.refine);

    return this;
  }
}
