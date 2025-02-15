import 'package:keeper/src/types/type.dart';
import 'package:keeper/src/validators/refine_validator.dart';

class KRefine<T> extends KType<T> {
  KRefine<T> refine(bool Function(T? data) validator, {String? message}) {
    add(RefineValidator<T>(validator, message: message!));

    return this;
  }
}
