import 'package:keeper/src/types/type.dart';

class KArray<T> {
  final KType<T> _type;

  KArray(this._type);

  bool validate(List<T> values) {
    for (final value in values) {
      final isValid = _type.validate(value);

      if (isValid) continue;
      return false;
    }

    return true;
  }
}
