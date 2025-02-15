import 'package:keeper/src/types/type.dart';
import 'package:keeper/src/validators/validator.dart';

class EveryValidator<T> extends KValidator<T> {
  final List<KType<T>> types;

  EveryValidator(this.types, {required super.message});

  @override
  String? validate(value) {
    for (final type in types) {
      final message = type.getErrorMessage(value);

      if (message != null) return message;
    }

    return null;
  }
}
