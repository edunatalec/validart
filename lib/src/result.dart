import 'package:validart/src/error.dart';

sealed class VResult<T> {
  const VResult();

  bool get isValid;
  bool get isNotValid => !isValid;
}

final class VSuccess<T> extends VResult<T> {
  final T value;

  const VSuccess(this.value);

  @override
  bool get isValid => true;
}

final class VFailure<T> extends VResult<T> {
  final List<VError> errors;

  const VFailure(this.errors);

  @override
  bool get isValid => false;

  Map<String, String> toMap() {
    final map = <String, String>{};
    for (final error in errors) {
      final key = error.pathString;
      if (key.isNotEmpty && !map.containsKey(key)) {
        map[key] = error.message;
      }
    }
    return map;
  }
}
